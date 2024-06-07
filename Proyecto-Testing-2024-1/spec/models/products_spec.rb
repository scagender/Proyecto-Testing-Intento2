# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  before(:each) do
    @user = User.create!(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @product = Product.new(
      nombre: 'Producto de prueba',
      precio: 4000,
      stock: 1,
      user: @user,
      categories: 'Cancha'
    )
  end

  describe "Validations" do
    it 'is valid with valid attributes' do
      expect(@product).to be_valid
    end

    it 'is not valid without a nombre' do
      @product.nombre = nil
      expect(@product).to_not be_valid
    end

    it 'is not valid without a category' do
      @product.categories = nil
      expect(@product).to_not be_valid
    end

    it 'is not valid with an invalid category' do
      @product.categories = 'Invalid Category'
      expect(@product).to_not be_valid
    end

    it 'is not valid without stock' do
      @product.stock = nil
      expect(@product).to_not be_valid
    end

    it 'is not valid with a negative stock' do
      @product.stock = -1
      expect(@product).to_not be_valid
    end

    it 'is not valid without a precio' do
      @product.precio = nil
      expect(@product).to_not be_valid
    end

    it 'is not valid with a negative precio' do
      @product.precio = -1
      expect(@product).to_not be_valid
    end

    it 'is not valid without a user' do
      @product.user = nil
      expect(@product).to_not be_valid
    end
  end

end
