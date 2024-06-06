require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    @user = User.create!(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
  end

  it "is valid with valid attributes" do
    expect(@user).to be_valid
  end

  it "is not valid without a name" do
    @user.name = nil
    expect(@user).to_not be_valid
  end

  it "is not valid with a short name" do
    @user.name = 'a'
    expect(@user).to_not be_valid
  end

  it "is not valid with a long name" do
    @user.name = 'a' * 26
    expect(@user).to_not be_valid
  end

  it "is not valid without an email" do
    @user.email = nil
    expect(@user).to_not be_valid
  end

  it "is not valid with a duplicate email" do
    user2 = User.new(name: 'John2', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin')
    expect(user2).to_not be_valid
  end

  it "has a valid admin? method" do
    expect(@user.admin?).to be true

    @user.role = 'user'
    expect(@user.admin?).to be false
  end

  it 'has many reviews' do
    review1 = @user.reviews.new(product: @product, tittle:"Buen producto", description: "Me gustó mucho", calification: 5)
    review2 = @product.reviews.new(product: @product, tittle:"Decente", description: "No me gustó tanto", calification: 3)
    expect(@product.reviews).to include(review1, review2)
  end

  it "destroys dependent products, reviews, messages, and solicitudes" do
    product = @user.products.create!(nombre: 'Producto de prueba', precio: 4000, stock: 1, categories: 'Cancha')
    review = @user.reviews.create!(product: product, tittle:"Buen producto", description: "Me gustó mucho", calification: 5)
    message = @user.messages.create!(product: product, body:"Buen producto")
    solicitud = @user.solicituds.create!(product: product, stock: 1, status: 'pending')

    expect { @user.destroy }.to change { Product.count }.by(-1)
      .and change { Review.count }.by(-1)
      .and change { Message.count }.by(-1)
      .and change { Solicitud.count }.by(-1)
  end

  describe "Validations" do

    it 'user in DB' do
      expect(@user.persisted?).to be true
    end

    it 'user erased from DB' do
      user = User.create(name: 'John', email: 'john111@example.com')
      user.destroy
      expect(user.persisted?).to be false
    end
    
    it 'user not in DB' do
      user = User.new(name: 'John', email: 'john111@example.com')
      expect(user.persisted?).to be false
    end

    it 'expects password if user has password' do
      @user.password = 'NewPassword123'
      expect(@user.password_required?).to be true
    end

    it 'expect password confirmation to be present' do
      @user.password_confirmation = 'NewPassword123'
      expect(@user.password_required?).to be true
    end

    it "is valid without a password" do
      @user.password = nil
      @user.password_confirmation = nil
      @user.validate_password_strength
      expect(@user).to be_valid
    end

    it "is valid with a strong password" do
      @user.password = 'Contraseña1!'
      @user.password_confirmation = 'Contraseña1!'
      @user.validate_password_strength
      expect(@user).to be_valid
    end
  
    it "is not valid without a digit" do
      @user.password = 'Contraseña!'
      @user.password_confirmation = 'Contraseña!'
      @user.validate_password_strength
      expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it "is not valid without a simbol" do
      @user.password = 'Contraseña'
      @user.password_confirmation = 'Contraseña'
      @user.validate_password_strength
      expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end
    
    it 'is not valid without an uppercase letter' do
      @user.password = 'contraseña1!'
      @user.password_confirmation = 'contraseña1!'
      @user.validate_password_strength
      expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it 'is not valid without an lower letter' do
      @user.password = 'CONTRASEÑA1!'
      @user.password_confirmation = 'CONTRASEÑA1!'
      @user.validate_password_strength
      expect(@user.errors[:password]).to include('no es válido incluir como minimo una mayuscula, minuscula y un simbolo')
    end

    it "validates deseados correctly" do
      expect(@user).to be_valid
      product = Product.create!(
        nombre: 'Product1',
        precio: 10.0,
        stock: 5,
        categories: 'Cancha',
        user: @user
      )
      @user.deseados << product.id
      @user.save
      expect(@user).to be_valid
  
      @user.deseados << 9999 # assuming 9999 is a non-existent product id
      @user.save
      expect(@user).to_not be_valid
      expect(@user.errors[:deseados]).to include('el articulo que se quiere ingresar a la lista de deseados no es valido')
          
    end
  end
end

  