module Etl
  class InventoryEtlService
    def initialize(source:, file: nil)
      @source = source # :csv o :api
      @file = file
    end

    def run
      data = extract
      normalized = Etl::Transform.normalize(data)
      valid = normalized.select { |p| Etl::Transform.valid?(p) }
      Etl::Load.apply(valid)
    end

    private

    def extract
      case @source
      when :csv
        Etl::Extract.from_csv(@file)
      when :api
        Etl::Extract.from_api
      else
        raise "source inválido"
      end
    end
  end
end
