module Etl
  class Extract
    # Extrae datos desde un CSV subido por el usuario
    def self.from_csv(file)
      require "csv"
      rows = []

      CSV.foreach(file.path, headers: true, col_sep: ",") do |row|
        rows << row.to_h.symbolize_keys
      end

      rows
    end

    # Extrae datos desde API externa
    def self.from_api
      require "net/http"
      require "json"

      url = URI("https://gist.githubusercontent.com/SamuelV19/cecc5401e6946a71598fcd4d416cdd36/raw/17ca9695a8fe5981512afef82e719e8998c8b5c2/catalogo_papeleria.json")
      response = Net::HTTP.get(url)
      JSON.parse(response, symbolize_names: true)
    end
  end
end
