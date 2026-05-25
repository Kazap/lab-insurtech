# Result base para retornos de service objects.
#
# Padrão:
#   def self.call(...)
#     return Result.failure(message: "...") if invalid
#     Result.success(data: ...)
#   end
#
# Uso:
#   result = SomeService.call(...)
#   if result.success?
#     do_something_with(result.data)
#   else
#     render json: { error: result.message }, status: :unprocessable_entity
#   end
#
class Result
  attr_reader :data, :message, :code

  def initialize(success:, data: nil, message: nil, code: nil)
    @success = success
    @data = data
    @message = message
    @code = code
  end

  def self.success(data: nil)
    new(success: true, data: data)
  end

  def self.failure(message:, code: nil)
    new(success: false, message: message, code: code)
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
