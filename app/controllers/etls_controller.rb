class EtlsController < ApplicationController
  def show
    @etl_logs = EtlLog.order(created_at: :desc).limit(50)
  end

  def run
    if params[:file].present?
      Etl::InventoryEtlService.new(source: :csv, file: params[:file]).run
    else
      Etl::InventoryEtlService.new(source: :api).run
    end

    redirect_to etl_path, notice: "ETL ejecutado correctamente"
  end
end
