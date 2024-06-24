# spec/system/products_spec.rb
require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    driven_by(:rack_test)
  end

  # Simular inicio de sesión como un usuario administrador
  def login_as_admin
    user = User.create!(name: 'Admin', email: 'admin@example.com', password: 'password', role: 'admin')
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  # Simular inicio de sesión como un usuario regular
  def login_as_user
    user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  it 'lists all products' do
    user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    Product.create!(nombre: 'Producto 1', precio: 100, stock: 10, categories: 'Cancha', user: user)
    Product.create!(nombre: 'Producto 2', precio: 200, stock: 5, categories: 'Cancha', user: user)

    visit '/products/index'

    expect(page).to have_content('Producto 1')
    expect(page).to have_content('Producto 2')
  end

  it 'searches products by category and name' do
    user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    Product.create!(nombre: 'Producto 1', precio: 100, stock: 10, categories: 'Cancha', user: user)
    Product.create!(nombre: 'Producto 2', precio: 200, stock: 5, categories: 'Campo', user: user)

    visit '/products/index'
    fill_in 'search', with: 'Producto 1'
    select 'Cancha', from: 'category'
    click_button 'Buscar'

    expect(page).to have_content('Producto 1')
    expect(page).not_to have_content('Producto 2')
  end

  it 'creates a new product as admin' do
    login_as_admin

    visit '/products/crear'

    fill_in 'Nombre', with: 'Nuevo Producto'
    fill_in 'Precio', with: 150
    fill_in 'Stock', with: 20
    fill_in 'Categories', with: 'Cancha'
    click_button 'Crear Producto'

    expect(page).to have_content('Producto creado Correctamente !')
    expect(page).to have_content('Nuevo Producto')
  end

  it 'updates a product as admin' do
    login_as_admin

    user = User.find_by(email: 'admin@example.com')
    product = Product.create!(nombre: 'Producto Actualizado', precio: 250, stock: 8, categories: 'Cancha', user: user)

    visit "/products/actualizar/#{product.id}"

    fill_in 'Nombre', with: 'Producto Actualizado Nuevo'
    fill_in 'Precio', with: 300
    fill_in 'Stock', with: 10
    click_button 'Actualizar Producto'

    expect(page).to have_content('Producto actualizado Correctamente!')
    expect(page).to have_content('Producto Actualizado Nuevo')
  end

  it 'deletes a product as admin' do
    login_as_admin

    user = User.find_by(email: 'admin@example.com')
    product = Product.create!(nombre: 'Producto a Eliminar', precio: 350, stock: 12, categories: 'Cancha', user: user)

    visit "/products/leer/#{product.id}"
    click_button 'Eliminar Producto'

    expect(page).to have_content('Producto eliminado correctamente')
    expect(Product.exists?(product.id)).to be_falsey
  end

  it 'adds a product to the wishlist' do
    login_as_user

    user = User.find_by(email: 'user@example.com')
    product = Product.create!(nombre: 'Producto Deseado', precio: 300, stock: 15, categories: 'Cancha', user: user)

    visit "/products/leer/#{product.id}"
    click_button 'Agregar a lista de deseados'

    expect(page).to have_content('Producto agregado a la lista de deseados')
    user.reload
    expect(user.deseados).to include(product.id.to_s)
  end

  it 'reads product details' do
    user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    product = Product.create!(nombre: 'Producto Detalle', precio: 400, stock: 20, categories: 'Cancha', user: user)
    review1 = product.reviews.create!(calification: 4, comment: 'Buen producto', user: user)
    review2 = product.reviews.create!(calification: 5, comment: 'Excelente producto', user: user)

    visit "/products/leer/#{product.id}"

    expect(page).to have_content('Producto Detalle')
    expect(page).to have_content('Buen producto')
    expect(page).to have_content('Excelente producto')
    expect(page).to have_content('4.5')
  end
end
