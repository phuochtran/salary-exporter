module Http
  def self.response(status_code, message)
    body = {
      status: status_code.to_i >= 200 && status_code.to_i < 300 ? 'SUCCESS' : 'ERROR',
      details: {
        message: message
      }
    }
    return [status_code, { 'content-type' => 'application/json' }, [body.to_json]]
  end
end
