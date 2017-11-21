class ConfigProxy
  include ConfigEndpoints

  def initialize(api_client)
    @api_client = api_client
  end

  def transaction(transaction_entity_id)
    @api_client.get(transaction_endpoint(transaction_entity_id))
  end

  def transactions
    @api_client.get(transactions_endpoint)
  end

  def get_idp_list(transaction_id)
    response = @api_client.get(idp_list_endpoint(transaction_id))
    IdpListResponse.validated_response(response)
  end
end
