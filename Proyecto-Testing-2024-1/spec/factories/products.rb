
FactoryBot.define do
    factory :product do
      sequence(:nombre) { |n| "Producto#{n}" }
      precio { 100.0 }
      stock { 10 }
      image { "image_url" }
      categories { "Category1, Category2" }
      horarios { "Lunes,Martes;Miércoles,Jueves" }
      user
    end
  end