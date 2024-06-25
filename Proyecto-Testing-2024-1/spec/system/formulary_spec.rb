# spec/system/products_spec.rb
require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    @admin = User.create!(name: 'Juan Gomez', email: 'admin@example.com', password: 'password', role: 'admin')
    @user = User.create!(name: 'Jose Gonzales', email: 'user@example.com', password: 'password', role: 'user')
  end

  it 'allows admin to create a product' do
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit '/products/crear'

    fill_in 'Nombre', with: 'Producto de prueba'
    fill_in 'Precio', with: 100
    fill_in 'Stock', with: 50
    select 'Cancha', from: 'product[categories]'
    fill_in 'Horarios', with: '26/06/2024,9:00,18:00'

    click_button 'Guardar'

    expect(page).to have_content('Producto creado Correctamente !')
    expect(page).to have_content('Producto de prueba')
  end

  it 'prevents non-admin from creating a product' do
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'
    visit '/products/crear'

    expect(page).to have_content('Esta página es exclusiva para administradores.')
  end

  it 'allows admin to update a product' do
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

  it 'prevents non-admin from updating a product' do
    product = Product.create!(nombre: 'Producto existente', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/actualizar/#{product.id}"

    expect(page).to have_content('No estás autorizado para acceder a esta página')
  end

  it 'allows admin to delete a product' do
    product = Product.create!(nombre: 'Producto a eliminar', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'
    
    visit "/products/index"

    expect(page).to have_content('Producto a eliminar')

    accept_confirm do
      click_button "Eliminar"
    end

    expect(page).not_to have_content('Producto a eliminar')
  end

  it 'prevents non-admin from deleting a product' do
    product = Product.create!(nombre: 'Producto a eliminar', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/index"

    expect(page).not_to have_link("Eliminar", href: "/products/eliminar/#{product.id}")
  end

  it 'allows user to add product to wishlist' do
    product = Product.create!(nombre: 'Producto de prueba', precio: 100, stock: 50, categories: 'Cancha',  horarios: '13/06/2024,14:00,16:00', user: @admin)
    
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Guardar en deseados'

    expect(page).to have_content('Producto agregado a la lista de deseados')
  end

  it 'searches for products by category' do
    Product.create!(nombre: 'Producto A', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    Product.create!(nombre: 'Producto B', precio: 200, stock: 30, categories: 'Equipamiento', user: @admin)

    visit '/products/index'
    select 'Cancha', from: 'category'
    click_button 'Filtrar por categoria'

    expect(page).to have_content('Producto A')
    expect(page).not_to have_content('Producto B')
  end

  it 'searches for products by name' do
    Product.create!(nombre: 'Producto A', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    Product.create!(nombre: 'Producto B', precio: 200, stock: 30, categories: 'Equipamiento', user: @admin)

    visit '/products/index'
    fill_in 'search', with: 'Producto A'
    click_button 'Buscar'

    expect(page).to have_content('Producto A')
    expect(page).not_to have_content('Producto B')
  end

  it 'searches for products by category and name' do
    Product.create!(nombre: 'Producto A', precio: 100, stock: 50, categories: 'Cancha', user: @admin)
    Product.create!(nombre: 'Producto B', precio: 200, stock: 30, categories: 'Cancha', user: @admin)
    Product.create!(nombre: 'Producto C', precio: 300, stock: 20, categories: 'Equipamiento', user: @admin)

    visit '/products/index'
    select 'Cancha', from: 'category'
    fill_in 'search', with: 'Producto A'
    click_button 'Buscar'

    expect(page).to have_content('Producto A')
    expect(page).not_to have_content('Producto B')
    expect(page).not_to have_content('Producto C')
  end
end

