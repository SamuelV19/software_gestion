require 'prawn'
require 'prawn/table'

class SaleInvoicePdf
  def initialize(sale)
    @sale = sale
    @pdf = Prawn::Document.new
    header
    body
    footer
  end

  def header
    @pdf.text "Factura de Venta", size: 20, style: :bold, align: :center
    @pdf.move_down 20

    @pdf.text "Cliente: #{@sale.nombre_cliente}"
    @pdf.text "Cédula / NIT: #{@sale.cedula}"
    @pdf.text "Dirección: #{@sale.direccion}"
    @pdf.move_down 20
  end

  def body
    data = [["Producto", "Cantidad", "Precio Unitario", "Subtotal"]]

    @sale.sale_items.each do |item|
      subtotal = item.cantidad * item.precio_unitario
      data << [item.product.nombre, item.cantidad, "$#{item.precio_unitario}", "$#{subtotal}"]
    end

    @pdf.table(data, header: true, width: @pdf.bounds.width) do
      row(0).font_style = :bold
      columns(2..3).align = :right
    end

    @pdf.move_down 15
    @pdf.text "Total: $#{@sale.total}", size: 16, style: :bold, align: :right
  end

  def footer
    @pdf.move_down 40
    @pdf.text "Gracias por su compra.", align: :center, style: :italic
  end

  def render
    @pdf.render
  end
end
