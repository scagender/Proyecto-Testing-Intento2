
require 'rails_helper'

RSpec.describe Message, type: :model do
    before(:each) do
      @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      @product = Product.create!(
        nombre: 'Producto de prueba',
        precio: 4000,
        stock: 1,
        user: @user,
        categories: 'Cancha'
      )
      @message = Message.new(
        body: 'Este es un mensaje de prueba',
        user: @user,
        product: @product
      )
    end
  
    describe "Validations" do
      it 'is valid with valid attributes' do
        expect(@message).to be_valid
      end
  
      it 'is not valid without a body' do
        @message.body = nil
        expect(@message).to_not be_valid
      end
  
      it 'is not valid without a user' do
        @message.user = nil
        expect(@message).to_not be_valid
      end
  
      it 'is not valid without a product' do
        @message.product = nil
        expect(@message).to_not be_valid
      end
    end
  end