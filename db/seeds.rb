# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  User.find_or_create_by!(email_address: ENV["ADMIN_EMAIL"]) do |user|
    user.password = ENV["ADMIN_PASSWORD"]
  end
end

[
  { name: "Vivienda VIS", slug: "vivienda-vis", requires_collateral: true, tax_deductible: true,
    description: "Crédito hipotecario para Vivienda de Interés Social" },
  { name: "Vivienda No VIS", slug: "vivienda-no-vis", requires_collateral: true, tax_deductible: true,
    description: "Crédito hipotecario para vivienda que no clasifica como VIS" },
  { name: "Vehículo", slug: "vehiculo", requires_collateral: true, tax_deductible: false,
    description: "Crédito con garantía prendaria sobre un vehículo" },
  { name: "Libre inversión", slug: "libre-inversion", requires_collateral: false, tax_deductible: false,
    description: "Crédito de consumo sin destinación específica ni garantía real" },
  { name: "Educativo", slug: "educativo", requires_collateral: false, tax_deductible: false,
    description: "Crédito para estudios, usualmente con período de gracia" },
  { name: "Consumo", slug: "consumo", requires_collateral: false, tax_deductible: false,
    description: "Crédito para compra de bienes o servicios de consumo" },
  { name: "Microcrédito", slug: "microcredito", requires_collateral: false, tax_deductible: false,
    description: "Crédito de bajo monto dirigido a microempresarios" }
].each do |attributes|
  CreditType.find_or_create_by!(slug: attributes[:slug]) do |credit_type|
    credit_type.assign_attributes(attributes)
  end
end
