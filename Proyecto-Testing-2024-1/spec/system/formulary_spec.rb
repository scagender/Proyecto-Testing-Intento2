# spec/system/products_spec.rb
require 'rails_helper'

RSpec.describe 'Products', type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    @admin = User.create!(name: 'Juan Gomez', email: 'admin@example.com', password: 'password', role: 'admin')
    @user = User.create!(name: 'Jose Gonzales', email: 'user@example.com', password: 'password', role: 'user')
  end
  # Products
  # Happy Path
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
  # Alternative Path 1
  it 'allows admin to create a product with error stock' do
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit '/products/crear'

    fill_in 'Nombre', with: 'Producto de prueba'
    fill_in 'Precio', with: 100
    fill_in 'Stock', with: 'veinte'
    select 'Equipamiento', from: 'product[categories]'

    click_button 'Guardar'

    expect(page).to have_content("Hubo un error al guardar el producto: Stock: no es un número")
  end
  # Alternative Path 2
  it 'allows admin to create a product with error precio' do
    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit '/products/crear'

    fill_in 'Nombre', with: 'Producto de prueba'
    fill_in 'Precio', with: 'cincuenta'
    fill_in 'Stock', with: 100
    select 'Equipamiento', from: 'product[categories]'

    click_button 'Guardar'

    expect(page).to have_content("Hubo un error al guardar el producto: Precio: no es un número")
  end
  # Alternative Path 3
  it 'prevents non-admin from creating a product' do
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'
    visit '/products/crear'

    expect(page).to have_content('Esta página es exclusiva para administradores.')
  end
  # Test extras

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
  # Edit User
  # Happy Path
  it 'edit user without change password' do
    user =  User.create!(name: 'Alexis Sanchez', email: 'asanchez@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Iniciar Sesión'

    visit "/edit"
                                    
    fill_in 'user[name]', with: 'Felipe Flores'
    fill_in 'user[email]', with: 'elgoleador@gmail.com'
    fill_in 'user[current_password]', with: 'password'

    click_button 'commit'

    expect(page).to have_content('Tu cuenta se ha actualizado exitosamente.')
  end
  # Happy Path 2
  it 'edit user with change password' do
    user =  User.create!(name: 'Alexis Sanchez', email: 'asanchez@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Iniciar Sesión'

    visit "/edit"
                                    
    fill_in 'user[name]', with: 'Felipe Flores'
    fill_in 'user[email]', with: 'elgoleador@gmail.com'
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[password_confirmation]', with: 'password123'
    fill_in 'user[current_password]', with: 'password'

    click_button 'commit'

    expect(page).to have_content('Tu cuenta se ha actualizado exitosamente.')
  end
  # Alternative Path 1
  it 'edit user with password short' do
    user =  User.create!(name: 'Alexis Sanchez', email: 'asanchez@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Iniciar Sesión'

    visit "/edit"
                                    
    fill_in 'user[name]', with: 'Felipe Flores'
    fill_in 'user[email]', with: 'elgoleador@gmail.com'
    fill_in 'user[password]', with: 'p123'
    fill_in 'user[password_confirmation]', with: 'p123'
    fill_in 'user[current_password]', with: 'password'

    click_button 'commit'

    expect(page).to have_content('Un error impidió que fuera guardado:')
    expect(page).to have_content('Password: es demasiado corto (6 caracteres mínimo)')
  end
  # Alternative Path 2
  it 'edit user without same password' do
    user =  User.create!(name: 'Alexis Sanchez', email: 'asanchez@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Iniciar Sesión'

    visit "/edit"
                                    
    fill_in 'user[name]', with: 'Felipe Flores'
    fill_in 'user[email]', with: 'elgoleador@gmail.com'
    fill_in 'user[password]', with: 'pass21341'
    fill_in 'user[password_confirmation]', with: 'pass3789193'
    fill_in 'user[current_password]', with: 'password'

    click_button 'commit'

    expect(page).to have_content('Un error impidió que fuera guardado:')
    expect(page).to have_content('Password confirmation: no coincide')
  end
  # Alternative Path 3
  it 'edit user without current password' do
    user =  User.create!(name: 'Alexis Sanchez', email: 'asanchez@example.com', password: 'password', role: 'user')
    visit '/login'
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'Iniciar Sesión'

    visit "/edit"
                                    
    fill_in 'user[name]', with: 'Felipe Flores'
    fill_in 'user[email]', with: 'elgoleador@gmail.com'
    fill_in 'user[current_password]', with: ''

    click_button 'commit'

    expect(page).to have_content('Un error impidió que fuera guardado:')
    expect(page).to have_content('Current password: no puede estar en blanco')
  end
end

=begin
# TEST DE FORMULARIOS CREADOS 

# NO FUNCIONALES
# Review
  it 'creates a new review' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Dejar una reseña'

    fill_in 'tittle', with: 'Buen producto'
    fill_in 'description', with: 'Este producto es muy bueno'
    # find('star13').click 
    select 'star13', from: 'rating'
    expect(find('calification_edit1', visible: false).value).to eq('3')

    within 'Crear una reseña' do
      click_button 'Crear'
    end 

    expect(page).to have_content('Review creado Correctamente !')
    expect(page).to have_content('Buen producto')
    expect(page).to have_content('Este producto es muy bueno')
    expect(find('calification_edit1', visible: false).value).to eq('3')
  end

  it 'updates an existing review' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    review = Review.create!(tittle: 'Buen producto', description: 'Este producto es bueno', calification: 4, product: product, user: @user)

    visit "/products/leer/#{product.id}"
    click_button 'Editar reseña'

    fill_in 'tittle', with: 'Excelente producto'
    fill_in 'description', with: 'Este producto es lo mejor.'
    #find('star15').click
    click_on 'star15'
    # Verificamos que el valor del campo oculto 'calification' se haya actualizado correctamente
    expect(find('calification_edit1', visible: false).value).to eq('5')
    click_button 'Actualizar reseña'

    review.update!(tittle: 'Excelente producto', description: 'Este producto es lo mejor.', calification: 5)
    expect(page).to have_content('Review actualizado Correctamente!')
    expect(page).to have_content('Excelente producto')
    expect(page).to have_content('Este producto es lo mejor.')
    expect(page).to have_content('5')
  end

  it 'deletes an existing review' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    review = Review.create!(tittle: 'Producto normal', description: 'Este producto es normal', calification: 3, product: product, user: @user)

    visit "/products/leer/#{product.id}"

    accept_alert do
      click_button 'Eliminar reseña'
    end
    expect(page).to have_content('127.0.0.1:3000 dice\n¿Estás seguro de que deseas eliminar esta reseña?')
    click_button 'Aceptar'
    expect(page).not_to have_content('Producto normal')
    expect(page).not_to have_content('Este producto es normal')
  end 
  # Comments
  it 'Create a comment' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    fill_in 'message[body]', with: '¿Bajaran los precios algun dia de estos?'

    click_button 'Crear'
    
    expect(page).to have_content('Pregunta creada correctamente!')
    expect(page).to have_content('¿Bajaran los precios algun dia de estos?')
  end
  it 'Create a comment without body message' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    fill_in 'message[body]', with: ''

    click_button 'Crear'
    
    expect(page).to have_content('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
  end
  it 'Answer a comment' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    message = Message.create!(body: '¿A cuanto el por mayor?',product_id: product.id, user_id: @admin.id)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Responder pregunta'

    fill_in 'message[body]', with: 'Se lo dejamos un 20% mas barato'

    click_button 'Enviar respuesta'
    expect(page).to have_content('Pregunta creada correctamente!')
    expect(page).to have_content('Se lo dejamos un 20% mas barato')
  end

  it 'Answer a comment without a body message' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    message = Message.create!(body: '¿A cuanto el por mayor?',product_id: product.id, user_id: @admin.id)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Responder pregunta'

    fill_in ''

    click_button 'Enviar respuesta'
    
    expect(page).to have_content('Hubo un error al guardar la pregunta. ¡Completa todos los campos solicitados!')
  end

  it 'Delete a comment' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    message = Message.create!(body: '¿A cuanto el por mayor?',product_id: product.id, user_id: @admin.id)

    visit '/login'
    fill_in 'user_email', with: @admin.email
    fill_in 'user_password', with: @admin.password
    click_button 'Iniciar Sesión'

    visit "/products/leer/#{product.id}"

    click_button 'Eliminar comentario'

    page.driver.browser.switch_to.alert.accept

    expect(page).to have_content('Alert text : ¿Estás seguro de que deseas eliminar este comentario?')
    click_button 'Aceptar'

    expect(page).not_to have_content('¿A cuanto el por mayor?')
  end

  #FUNCIONALES
    # Shopping Car
  it 'Buy a product with delivery' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { product.id.to_s => 1 })
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/carro/detalle"
    
    choose 'Envío a domicilio'
    expect(page).to have_checked_field('Envío a domicilio')
                                    
    fill_in 'nombre', with: 'Felipe Flores'
    fill_in 'direccion', with: 'El salitre 3421'
    fill_in 'comuna', with: 'Pudahuel'
    fill_in 'region', with: 'Metropolitana'

    click_button 'Pagar'
    expect(page).to have_content('Compra realizada exitosamente')
  end
  it 'Buy a product without delivery' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { product.id.to_s => 1 })
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/carro/detalle"
    
    choose 'Retiro en tienda'
    expect(page).to have_checked_field('Retiro en tienda')

    click_button 'Pagar'
    
    expect(page).to have_content('Compra realizada exitosamente')
  end
    # Contact Message

  it 'Create a contact message' do
    product = Product.create!(nombre: 'Producto Test', precio: 200, stock: 100, categories: 'Cancha',horarios: '14/06/2024,14:00,16:00',  user: @admin)
    visit '/login'
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: @user.password
    click_button 'Iniciar Sesión'

    visit "/contacto"

    fill_in 'contact[name]', with: 'Esteban Paredes'
    fill_in 'contact[mail]', with: 'lomejordecolocolo@gmail.com'
    fill_in 'contact[title]', with: '¿Funcionara la aplicacion bien algun dia?'
    fill_in 'contact[body]', with: 'No me funcionan los apartados de comprar y de solicitudes, avisenme cuando los arreglen'

    click_button 'Enviar'
    
    expect(page).to have_content('Mensaje de contacto enviado correctamente')
  end
=end