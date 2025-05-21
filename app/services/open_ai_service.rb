require "openai"

class OpenAiService
  def initialize
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      organization_id: ENV['OPENAI_ORG_ID']
    )
  end
  

  def analyze_sales_report(sales_summary)
    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo", 
        messages: [
          { role: "system", content: "Eres un analista de datos de ventas. Resume el rendimiento del negocio." },
          { role: "user", content: "Resumen de ventas: #{sales_summary}" }
        ]
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue Faraday::TooManyRequestsError => e
    Rails.logger.warn "Rate limit alcanzado. Espera sugerida: unos momentos"
    "Rate limit alcanzado. Intenta de nuevo en unos minutos."
  rescue Faraday::UnauthorizedError => e
    Rails.logger.error "Token no autorizado: #{e.message}"
    "La clave de API no es válida o fue revocada."
  rescue => e
    Rails.logger.error "Error general: #{e.message}"
    "Ocurrió un error al procesar el análisis con IA."
  end
end


