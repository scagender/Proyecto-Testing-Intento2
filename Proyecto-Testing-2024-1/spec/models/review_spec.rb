require 'rails_helper'

RSpec.describe Review, type: :model do
  before(:each) do
    @user = User.create!(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    @product = Product.create!(nombre: 'Producto 1', precio: 1000, stock: 10, user: @user, categories: 'Cancha')
    @review = Review.new(
      tittle: 'Great Product',
      description: 'This is a great product',
      calification: 5,
      user: @user,
      product: @product
    )
  end

  describe "Validations" do
    it 'is valid with valid attributes' do
      expect(@review).to be_valid
    end

    it 'is not valid without a tittle' do
      @review.tittle = nil
      expect(@review).to_not be_valid
    end

    it 'is not valid with a tittle longer than 100 characters' do
      @review.tittle = 'a' * 101
      expect(@review).to_not be_valid
    end

    it 'is not valid without a description' do
      @review.description = nil
      expect(@review).to_not be_valid
    end

    it 'is not valid with a description longer than 500 characters' do
      @review.description = 'a' * 501
      expect(@review).to_not be_valid
    end

    it 'is not valid without a calification' do
      @review.calification = nil
      expect(@review).to_not be_valid
    end

    it 'is not valid with a calification less than 1' do
      @review.calification = 0
      expect(@review).to_not be_valid
    end

    it 'is not valid with a calification greater than 5' do
      @review.calification = 6
      expect(@review).to_not be_valid
    end

    it 'is not valid without a product' do
      @review.product = nil
      expect(@review).to_not be_valid
    end

    it 'is not valid without a user' do
      @review.user = nil
      expect(@review).to_not be_valid
    end
  end
end