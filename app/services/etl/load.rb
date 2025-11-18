module Etl
  class Load
    def self.apply(products)
      products.each do |p|
        nombre = p[:nombre].to_s.strip
        descripcion = p[:descripcion].to_s.strip
        precio = p[:precio].to_f
        stock = p[:stock].to_i

        # Saltar productos corruptos
        unless Etl::Transform.valid?(p)
          Rails.logger.warn("Producto corrupto ignorado: #{nombre}")
          next
        end

        # Buscar producto existente (ignorando mayúsculas)
        product = Product.where("LOWER(nombre) = ?", nombre.downcase).first

        if product.nil?
          # Crear producto nuevo
          new_product = Product.create(
            nombre: nombre,
            descripcion: descripcion,
            precio: precio,
            stock: stock
          )

          if new_product.persisted?
            EtlLog.create!(
              product_id: new_product.id,
              cambio: "nuevo_producto",
              valor_anterior: "-",
              valor_nuevo: new_product.to_json
            )
          end

          next
        end

        # Revisar cambios en producto existente
        cambios_detectados = {}

        {
          descripcion: descripcion,
          precio: precio,
          stock: stock
        }.each do |campo, nuevo_valor|
          valor_anterior = product[campo]

          next if valor_anterior.to_s == nuevo_valor.to_s

          # Registrar cambio
          cambios_detectados[campo] = {
            anterior: valor_anterior,
            nuevo: nuevo_valor
          }

          # Actualizar campo
          product[campo] = nuevo_valor
        end

        # Guardar y crear logs solo si hubo cambios
        if cambios_detectados.any? && product.save
          cambios_detectados.each do |campo, vals|
            EtlLog.create!(
              product_id: product.id,
              cambio: campo.to_s,
              valor_anterior: vals[:anterior],
              valor_nuevo: vals[:nuevo]
            )
          end
        end
      end
    end
  end
end
