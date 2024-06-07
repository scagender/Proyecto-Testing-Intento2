# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
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

    it 'is not valid without a category' do
      @product.categories = nil
      expect(@product).to_not be_valid
    end

    it 'is not valid with an invalid category' do
      @product.categories = 'Invalid Category'
      expect(@product).to_not be_valid
    end

    it 'is not valid without a nombre' do
      @product.nombre = nil
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

  describe "Associations" do
    it 'belongs to a user' do
      expect(@product.user).to eq(@user)
    end

    it 'has many reviews' do
      review1 = @product.reviews.new(user: @user, product: @product, tittle:"Buen producto", description: "Me gustó mucho", calification: 5)
      review2 = @product.reviews.new(user: @user, product: @product, tittle:"Decente", description: "No me gustó tanto", calification: 3)
      expect(@product.reviews).to include(review1, review2)
    end

    it 'has many messages' do
      @product.save
      message1 = @product.messages.new(user: @user, product: @product, body:"Buen producto")
      message2 = @product.messages.new(user: @user, product: @product, body:"No muy buen producto")
      expect(@product.messages).to include(message1, message2)
    end

    it 'has many solicituds' do
      @product.save
      solicitud1 = @product.solicituds.new(user: @user, product: @product, stock: 1, status: 'pending')
      solicitud2 = @product.solicituds.new(user: @user, product: @product, stock: 2, status: 'ready')
      expect(@product.solicituds).to include(solicitud1, solicitud2)
    end

    it 'destroys associated reviews when product is destroyed' do
      @product.save
      review = @product.reviews.create(user: @user, product: @product, tittle:"Buen producto", description: "Me gustó mucho", calification: 5)
      expect { @product.destroy }.to change { Review.count }.by(-1)
    end

    it 'destroys associated messages when product is destroyed' do
      @product.save
      message = @product.messages.create(user: @user, product: @product, body:"Buen producto")
      expect { @product.destroy }.to change { Message.count }.by(-1)
    end

    it 'destroys associated solicituds when product is destroyed' do
      @product.save
      solicitud = @product.solicituds.create(user: @user, product: @product, stock: 1, status: 'pending')
      expect { @product.destroy }.to change { Solicitud.count }.by(-1)
    end
  end

  describe "Attachments" do
    it 'can have an image attached' do
      @product.image.attach(
        io: File.open(Rails.root.join('app', 'assets', 'images', 'base.jpg')),
        filename: 'base.jpg',
        content_type: 'base/jpg'
      )
      expect(@product.image).to be_attached
    end
  end

end