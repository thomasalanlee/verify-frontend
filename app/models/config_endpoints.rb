module ConfigEndpoints
  PATH = '/config'.freeze
  PATH_PREFIX = Pathname(PATH)
  IDP_LIST_SUFFIX = 'idps/idp-list'.freeze
  TRANSACTION_SUFFIX = 'transactions/%s/display-data'.freeze
  TRANSACTIONS_SUFFIX = 'transactions/enabled'.freeze

  def idp_list_endpoint(transaction_id)
    transaction_id_query_parameter = { transactionEntityId: transaction_id }.to_query
    PATH_PREFIX.join(IDP_LIST_SUFFIX).to_s + "?#{transaction_id_query_parameter}"
  end

  def transaction_endpoint(transaction_entity_id)
    PATH_PREFIX.join(format(TRANSACTION_SUFFIX, CGI.escape(transaction_entity_id))).to_s
  end

  def transactions_endpoint
    PATH_PREFIX.join(TRANSACTIONS_SUFFIX).to_s
  end
end
