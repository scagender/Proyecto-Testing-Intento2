require 'rails_helper'

RSpec.describe Solicitud, type: :model do
  before(:each) do
    @user = User.create!(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @product = Product.create!(nombre: 'Producto 1', precio: 1000, stock: 10, user: @user, categories: 'Cancha')
    @solicitud = Solicitud.new(
      stock: 5,
      status: 'pending',
      user: @user,
      product: @product
    )
  end

  describe "Validations" do
    it 'is valid with valid attributes' do
      expect(@solicitud).to be_valid
    end

    it 'is not valid without a stock' do
      @solicitud.stock = nil
      expect(@solicitud).to_not be_valid
    end

    it 'is not valid with a non-integer stock' do
      @solicitud.stock = 1.5
      expect(@solicitud).to_not be_valid
    end

    it 'is not valid with a stock less than or equal to 0' do
      @solicitud.stock = 0
      expect(@solicitud).to_not be_valid
    end

    it 'is not valid without a status' do
      @solicitud.status = nil
      expect(@solicitud).to_not be_valid
    end

    it 'is not valid without a product' do
      @solicitud.product = nil
      expect(@solicitud).to_not be_valid
    end

    it 'is not valid without a user' do
      @solicitud.user = nil
      expect(@solicitud).to_not be_valid
    end
  end
end