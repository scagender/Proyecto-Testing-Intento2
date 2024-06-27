require 'rails_helper'

RSpec.describe 'Navigation', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  before(:each) do
    
    @admin = User.create!(name: 'Admin', email: 'admin53@example.com', password: 'password', role: 'admin')
    @user = User.create!(name: 'User', email: 'user@example.com', password: 'password', role: 'user')
    @product1 = Product.create!(nombre: 'Producto 1', precio: 100, stock: 10, categories: 'Cancha', horarios: '13/06/2024,14:00,16:00', user: @admin)
    @product2 = Product.create!(nombre: 'Producto 2', precio: 200, stock: 5, categories: 'Cancha', horarios: '13/06/2024,12:00,13:00;14/06/2024,12:00,13:00', user: @admin)
  end

  after(:each) do
    User.destroy_all
    Product.destroy_all
  end

  it 'Register, see all normal user functions and logout', :js => true do

    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit root_path
    find('a[href="/register"]', text: 'Regístrate').click
    fill_in 'user[email]', with: 'user2@example.com'
    fill_in 'user_name', with: 'User2'
    fill_in 'user_password', with: 'password'
    fill_in 'user_password_confirmation', with: 'password'
    click_button 'Registrarse'

    find('a.button.is-dark', text:'Ver canchas y productos').click
    expect(page).to have_content('Producto 1')
    expect(page).to have_content('Producto 2')

    find_link('Mi cuenta', :visible => :all).hover
    find_link('Mi perfil', :visible => :all).click
    expect(page).to have_content('user2@example.com')

    find_link('Mi cuenta', :visible => :all).hover
    find_link('Solicitudes de compra y reserva', :visible => :all).click
    expect(page).to have_content('Mis solicitudes de reserva y compra pendientes')

    find_link('Mi cuenta', :visible => :all).hover
    find_link('Lista de deseos', :visible => :all).click
    expect(page).to have_content('Mis canchas y productos deseados')

    find_link('Mi cuenta', :visible => :all).hover
    find_link('Mis mensajes', :visible => :all).click
    expect(page).to have_content('Buzón de mensajes')

    find_link('Mi cuenta', :visible => :all).hover
    click_button 'Cerrar Sesión'
    expect(page).to have_content('Ver canchas y productos')

  end

  it 'Login, see a product, add it to the wishlist and go to contact form', :js => true do

    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit root_path
    find_link('Iniciar Sesión', :visible => :all).click
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    find('a.button.is-dark', text:'Ver canchas y productos').click
    expect(page).to have_content('Producto 1')
    expect(page).to have_content('Producto 2')

    find(:xpath, '/html/body/div/div[2]/div[1]/div/footer/a').click
    expect(page).to have_content('Producto 1')

    click_button 'Guardar en deseados'
    expect(page).to have_content('Producto agregado a la lista de deseados')

    find_link('Mi cuenta', :visible => :all).hover
    find_link('Lista de deseos', :visible => :all).click
    expect(page).to have_content('Producto 1')

    find_link('Contacto', :visible => :all).click
    expect(page).to have_content('Nombre*')
    expect(page).to have_content('Correo electrónico*')
    

  end

  it 'Login, see a product, add it to the cart and go to pay', :js => true do

    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit root_path
    find_link('Iniciar Sesión', :visible => :all).click
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    find('a.button.is-dark', text:'Ver canchas y productos').click
    expect(page).to have_content('Producto 1')
    expect(page).to have_content('Producto 2')

    find(:xpath, '/html/body/div/div[2]/div[1]/div/footer/a').click
    expect(page).to have_content('Producto 1')

    click_button 'Reservar ahora'
    expect(page).to have_content('Solicitud de compra creada correctamente!')

    find_link('Mi carrito', :visible => :all).click
    sleep 4
    find_link('Mi carrito', :visible => :all).hover
    sleep 4
    find(:xpath, '/html/body/header/nav/div[2]/div[2]/div[1]/a').hover
    find(:xpath, '/html/body/header/nav/div[2]/div[2]/div[1]/div/form[1]/button').click
    expect(page).to have_content('Tu carrito de compras')

    find(:xpath, '/html/body/header/nav/div[2]/div[2]/div[1]/a').hover
    find(:xpath, '/html/body/header/nav/div[2]/div[2]/div[1]/div/form[2]/button').click
    expect(page).to have_content('No tienes productos que comprar.')

  end

  it 'Login, see a product, add it to the cart and go to pay', :js => true do

    page.driver.browser.manage.window.resize_to(1920, 1080)
    visit root_path
    find_link('Iniciar Sesión', :visible => :all).click
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    find_link('Productos', :visible => :all).hover
    find(:xpath, '/html/body/header/nav/div[2]/div[1]/div/div/a[2]').click
    expect(page).to have_content('Crear Producto')

    fill_in 'product[nombre]', with: 'Producto de ejemplo'
    fill_in 'product[precio]', with: '1000'
    fill_in 'product[stock]', with: '10'
    fill_in 'product[horarios]', with: '13/06/2024,14:00,16:00'
    click_button 'Guardar'
    expect(page).to have_content('Producto de ejemplo')

    find(:xpath, '/html/body/div[2]/div[2]/div[3]/div/footer/a[2]').click
    expect(page).to have_content('Actualizar Producto')
    fill_in 'product[stock]', with: '15'
    click_button 'Guardar'
    expect(page).to have_content('Producto de ejemplo')

    find(:xpath, '/html/body/div/div[2]/div[3]/div/footer/form/button').click
    page.driver.browser.switch_to.alert.accept
    expect(page).not_to have_content('Producto de ejemplo')
  end

end
