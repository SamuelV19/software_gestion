class SalesController < ApplicationController
  def new
    @sale = Sale.new
    @products = Product.where('stock > 0')
  end

  def create
    # Filtramos los items con cantidad > 0
    items_params = params[:sale_items]&.select { |item| item[:cantidad].to_i > 0 }
    if items_params.blank?
      flash.now[:alert] = "Debe seleccionar al menos un producto con cantidad mayor a cero."
      @products = Product.where('stock > 0')
      @sale = Sale.new(sale_params)
      return render :new
    end

    begin
      ActiveRecord::Base.transaction do
        # Convertimos con_factura a booleano
        con_factura = sale_params[:con_factura] == "1"

        # Creamos la venta sin total y con fecha actual
        @sale = Sale.new(
          sale_params.except(:con_factura, :nombre_cliente, :cedula, :direccion)
                    .merge(total: 0, fecha: Time.zone.now)
        )
        total = 0

        # Creamos los items y descontamos stock
        items_params.each do |item|
          product = Product.find(item[:product_id])
          cantidad = item[:cantidad].to_i

          raise "Stock insuficiente para #{product.nombre}" if product.stock < cantidad

          total += cantidad * product.precio

          @sale.sale_items.build(
            product: product,
            cantidad: cantidad,
            precio_unitario: product.precio
          )

          product.decrement!(:stock, cantidad)
        end

        @sale.total = total

        # Validamos solo si con_factura es true
        if con_factura
          if sale_params[:nombre_cliente].blank? || sale_params[:cedula].blank? || sale_params[:direccion].blank?
            raise ActiveRecord::RecordInvalid.new(@sale)
          end
          # Asignamos datos de factura a la venta
          @sale.nombre_cliente = sale_params[:nombre_cliente]
          @sale.cedula = sale_params[:cedula]
          @sale.direccion = sale_params[:direccion]
          @sale.con_factura = true
        else
          # Si no hay factura, asegurar que no tenga datos de factura
          @sale.con_factura = false
          @sale.nombre_cliente = nil
          @sale.cedula = nil
          @sale.direccion = nil
        end

        @sale.save!

        if con_factura
          @sale.create_invoice!(
            numero: "FAC-#{@sale.id.to_s.rjust(6, '0')}",
            nombre_cliente: @sale.nombre_cliente,
            cedula: @sale.cedula,
            direccion: @sale.direccion,
            total: @sale.total,
            fecha_emision: Time.zone.now
          )
        end
      end

      redirect_to sale_path(@sale), notice: '¡Venta registrada con éxito!'
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.join(", ")
      @products = Product.where('stock > 0')
      @sale ||= Sale.new(sale_params)
      render :new
    rescue => e
      flash.now[:alert] = "Error al registrar venta: #{e.message}"
      @products = Product.where('stock > 0')
      @sale ||= Sale.new(sale_params)
      render :new
    end
  end
  

  def index
    @sales = Sale.order(created_at: :desc)
  
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
  
      @sales = @sales.where(fecha: start_date..end_date)
    end
  
    @total_ventas = @sales.sum(:total)
    @cantidad_ventas = @sales.count
  end
  

  def cancel
    @sale = Sale.find(params[:id])

    if @sale.anulada
      redirect_to sales_path, alert: "Esta venta ya está anulada."
      return
    end

    ActiveRecord::Base.transaction do
      # Revertir stock
      @sale.sale_items.each do |item|
        item.product.increment!(:stock, item.cantidad)
      end

      @sale.update!(anulada: true)
    end

    redirect_to sales_path, notice: "Venta anulada y stock restaurado correctamente."
  end

  def show
    @sale = Sale.find(params[:id])
  end

  def invoice_pdf
    @sale = Sale.find(params[:id])

    if @sale.invoice.present?
      pdf = SaleInvoicePdf.new(@sale)

      send_data pdf.render,
                filename: "Factura-#{@sale.invoice.numero}.pdf",
                type: "application/pdf",
                disposition: "inline"
    else
      redirect_to sale_path(@sale), alert: "Esta venta no tiene factura generada."
    end
  end

  private

  def sale_params
    params.permit(
      :con_factura, :nombre_cliente, :cedula, :direccion
    )
  end
end
