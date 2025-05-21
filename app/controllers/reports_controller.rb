class ReportsController < ApplicationController
  Rails.logger.info "¿Key presente? #{ENV['OPENAI_API_KEY'].present?}"
  def sales_summary
    start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    end_date = params[:end_date]&.to_date || Date.today

    @daily_sales = Sale.where(fecha: start_date..end_date)
                       .group("DATE(fecha)")
                       .select("DATE(fecha) as day, SUM(total) as total_sales, COUNT(*) as total_sales_count")
                       .order("day")

    @weekly_sales = Sale.where(fecha: start_date..end_date)
                        .group("DATE_TRUNC('week', fecha)")
                        .select("DATE_TRUNC('week', fecha) as week_start, SUM(total) as total_sales, COUNT(*) as total_sales_count")
                        .order("week_start")

    @monthly_sales = Sale.where(fecha: start_date..end_date)
                         .group("DATE_TRUNC('month', fecha)")
                         .select("DATE_TRUNC('month', fecha) as month_start, SUM(total) as total_sales, COUNT(*) as total_sales_count")
                         .order("month_start")

  end

  def export_csv
    require 'csv'

    start_date = params[:start_date]&.to_date || 1.month.ago.to_date
    end_date = params[:end_date]&.to_date || Date.today

    sales = Sale.where(fecha: start_date..end_date).order(:fecha)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["ID Venta", "Fecha", "Total", "Factura", "Nombre Cliente"]
      sales.each do |sale|
        csv << [sale.id, sale.fecha.strftime("%d/%m/%Y %H:%M"), sale.total, sale.con_factura ? "Sí" : "No", sale.nombre_cliente]
      end
    end

    send_data csv_data, filename: "sales_report_#{start_date}_to_#{end_date}.csv"
  end
end
