require 'rails_helper'

RSpec.describe User, type: :model do
    it "is valid with valid attributes" do
      user = User.new(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user).to be_valid
    end
  
    it "is not valid without a name" do
      user = User.new(name: nil, password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user).to_not be_valid
    end
  
    it "is not valid without an email" do
      user = User.new(name: 'John1', password: 'Nonono123!', email: nil, role: 'admin')
      expect(user).to_not be_valid
    end
  
    it "is not valid without a password" do
      user = User.new(name: 'John1', email: 'asdf@gmail.com', password: nil, role: 'admin')
      expect(user).to_not be_valid
    end
  
    it "is not valid with a short name" do
      user = User.new(name: 'J', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user).to_not be_valid
    end
  
    it "is not valid with a long name" do
      user = User.new(name: 'J' * 26, password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user).to_not be_valid
    end
  
    it "is not valid with a duplicate email" do
      user1 = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      user2 = User.new(name: 'John2', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user2).to_not be_valid
    end
  
    it "has a valid admin? method" do
      user = User.new(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      expect(user.admin?).to be true
  
      user.role = 'user'
      expect(user.admin?).to be false
    end
  
    it "validates deseados correctly" do
      user = User.create!(
        name: 'John1',
        password: 'Nonono123!',
        email: 'asdf@gmail.com',
        role: 'admin',
      )
      expect(user).to be_valid
      product = Product.create!(
        nombre: 'Product1',
        precio: 10.0,
        stock: 5,
        categories: 'Cancha',
        user: user
      )
      user.deseados << product.id
      user.save
      expect(user).to be_valid

      user.deseados << 9999 # assuming 9999 is a non-existent product id
      user.save
      expect(user).to_not be_valid
      expect(user.errors[:deseados]).to include('el articulo que se quiere ingresar a la lista de deseados no es valido')
          
    end
  
    it "destroys dependent products, reviews, messages, and solicitudes" do
      user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
      product = user.products.create!(nombre: 'Product1', precio: 10.0, stock: 5, categories: 'Cancha',)
      review = user.reviews.create!(tittle: 'Great product', description: 'I really enjoyed this product', calification: 5, product: product)
      message = user.messages.create!(body: 'Is this available?', product: product)
      solicitud = user.solicituds.create!(stock: 10, status: 'pending', product: product)
  
      expect { user.destroy }.to change { Product.count }.by(-1)
        .and change { Review.count }.by(-1)
        .and change { Message.count }.by(-1)
        .and change { Solicitud.count }.by(-1)
    end

    describe "Methods" do
      it "has a valid password_required? method" do
        user = User.new(name: 'John1', email: 'asdf@gmail.com', role: 'admin')
        # Test cases for password_required? method
        expect(user.password_required?).to be true # or false based on your implementation
      end
    
      it "has a valid validate_password_strength method" do
        user = User.new(name: 'John1', email: 'asdf@gmail.com', role: 'admin')
        user.password = 'WeakPassword123'
        user.validate_password_strength
        expect(user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
      end
    end
  end
