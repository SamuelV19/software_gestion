module Etl
  class Transform
    def self.normalize(products)
      products.map do |p|
        {
          nombre: p[:nombre]&.strip&.titleize,
          descripcion: (p[:descripcion] || "").strip,
          precio: p[:precio].to_f.round(2),
          stock: p[:stock].to_i,
          categoria: (p[:categoria] || "General").titleize
        }
      end
    end

    def self.valid?(product)
      product[:nombre].present? && product[:precio] > 0
    end
  end
end
