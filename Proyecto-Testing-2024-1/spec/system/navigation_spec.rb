require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    driven_by(:rack_test)
  end

  # Simular inicio de sesión como un usuario administrador
  def login_as_admin
    @admin = User.create!(name: 'Admin', email: 'admin53@example.com', password: 'password', role: 'admin')
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'
  end

  # Simular inicio de sesión como un usuario regular
  def login_as_user
    @user = User.create!(name: 'User', email: 'user24@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'
  end

  before(:each) do
    @admin = User.create!(name: 'Admin', email: 'admin53@example.com', password: 'password', role: 'admin')
    @user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    @product1 = Product.create!(nombre: 'Producto 1', precio: 100, stock: 10, categories: 'Cancha', user: @user)
    @product2 = Product.create!(nombre: 'Producto 2', precio: 200, stock: 5, categories: 'Cancha', user: @user)
  end

  after(:each) do
    User.destroy_all
    Product.destroy_all
  end

  it 'lists all products' do
    visit '/products/index'

    expect(page).to have_content('Producto 1')
    expect(page).to have_content('Producto 2')
  end

  it 'searches products by category and name' do
    visit '/products/index'
    fill_in 'search', with: 'Producto 1'
    select 'Cancha', from: 'category'
    click_button 'Buscar'

    expect(page).to have_content('Producto 1')
    expect(page).not_to have_content('Producto 2')
  end

  it 'creates a new product as admin' do
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit '/products/crear'

    fill_in 'Nombre', with: 'Nuevo Producto'
    fill_in 'Precio', with: 150
    fill_in 'Stock', with: 20
    select 'Cancha', from: 'product[categories]'
    click_button 'Guardar'

    expect(page).to have_content('Producto creado Correctamente !')
    expect(page).to have_content('Nuevo Producto')
  end

  it 'updates a product as admin' do
    product = Product.create!(nombre: 'Producto existente', precio: 100, stock: 50, categories: 'Cancha', user: @admin)

    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit "/products/actualizar/#{product.id}"

    fill_in 'Nombre', with: 'Producto actualizado'
    click_button 'Guardar'

    expect(page).to have_content('Producto actualizado')
  end

  it 'adds a product to the wishlist' do
    product = Product.create!(nombre: 'Producto de prueba', precio: 100, stock: 50, categories: 'Cancha',  horarios: '13/06/2024,14:00,16:00', user: @admin)
    
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Guardar en deseados'

    expect(page).to have_content('Producto agregado a la lista de deseados')
  end

  it 'reads product details' do
    product = Product.create!(nombre: 'Producto Detalle', precio: 400, stock: 20, categories: 'Cancha', user: @user)
    review1 = product.reviews.create!(tittle: 'review1', calification: 4, description: 'Buen producto', user: @user)
    review2 = product.reviews.create!(tittle: 'review2', calification: 5, description: 'Excelente producto', user: @user)

    visit "/products/leer/#{product.id}"

    expect(page).to have_content('Producto Detalle')
    expect(page).to have_content('Buen producto')
    expect(page).to have_content('Excelente producto')
    expect(page).to have_content('4.5')
  end
end
