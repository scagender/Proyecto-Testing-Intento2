require 'rails_helper'

RSpec.describe ShoppingCart, type: :model do
  before(:each) do
    @user = User.create!(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @product1 = Product.create!(nombre: 'Producto 1', precio: 1000, stock: 10, user: @user, categories: 'Cancha')
    @product2 = Product.create!(nombre: 'Producto 2', precio: 2000, stock: 20, user: @user, categories: 'Cancha')
    @shopping_cart = ShoppingCart.new(user: @user, products: { @product1.id => 2, @product2.id => 3 })
  end

  describe "Validations" do
    it 'is valid with valid attributes' do
      expect(@shopping_cart).to be_valid
    end

    it 'is not valid without a user' do
      @shopping_cart.user = nil
      expect(@shopping_cart).to_not be_valid
    end

    it 'is valid with empty products' do
      @shopping_cart.products = {}
      expect(@shopping_cart).to be_valid
    end

    it 'is valid with valid products' do
      expect(@shopping_cart.products).to include(@product1.id.to_s => 2, @product2.id.to_s => 3)
    end
  end

  describe "Instance methods" do
    describe "#precio_total" do
      it 'calculates the total price of the products in the cart' do
        expect(@shopping_cart.precio_total).to eq(8000) # 2 * 1000 + 3 * 2000
      end

      it 'returns zero if there are no products in the cart' do
        @shopping_cart.products = {}
        expect(@shopping_cart.precio_total).to eq(0)
      end

      it 'does not include prices of non-existent products' do
        @shopping_cart.products = { 9999 => 2 }
        expect(@shopping_cart.precio_total).to eq(0)
      end
    end

    describe "#costo_envio" do
      it 'calculates the shipping cost of the products in the cart' do
        expect(@shopping_cart.costo_envio).to eq(1400) # 1000 + (2 * 1000 * 0.05) + (3 * 2000 * 0.05)
      end

      it 'returns base shipping cost if there are no products in the cart' do
        @shopping_cart.products = {}
        expect(@shopping_cart.costo_envio).to eq(1000)
      end

      it 'does not include shipping costs of non-existent products' do
        @shopping_cart.products = { 9999 => 2 }
        expect(@shopping_cart.costo_envio).to eq(1000)
      end
    end
  end
end