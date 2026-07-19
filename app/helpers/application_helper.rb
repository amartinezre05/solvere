module ApplicationHelper
  def format_cop(amount)
    number_to_currency(amount, unit: "$", separator: ",", delimiter: ".", precision: 0)
  end
end
