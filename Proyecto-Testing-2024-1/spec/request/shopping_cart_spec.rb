require 'rails_helper'

RSpec.describe 'ShoppingCart', type: :request do
  before do
    @user = User.create!(name: 'Juan Gomez', email: 'jgomez5@example.com', password: 'Example123!')
    @product = Product.create!(nombre: 'Test Product', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
    sign_in @user
  end

  describe 'GET /carro' do
    context 'when user is signed in' do
      it 'creates a new shopping cart if not exist' do
        expect(ShoppingCart.find_by(user_id: @user.id)).to be_nil
        get '/carro'
        expect(assigns(:shopping_cart)).to be_present
        expect(assigns(:shopping_cart).user_id).to eq(@user.id)
      end
    end

    context 'when user is not signed in' do
      before { sign_out @user }

      it 'does not create a shopping cart' do
        get '/carro'
        expect(assigns(:shopping_cart)).to be_nil
      end
    end
  end

  describe 'GET /carro/detalle' do
    context 'when user is signed in' do
      before do
        @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
      end

      it 'shows the shopping cart details' do
        get '/carro/detalle'
        expect(response).to have_http_status(:ok)
        expect(assigns(:total_pago)).to eq(@shopping_cart.precio_total + @shopping_cart.costo_envio)
      end
    end

    ## APLICAR DONDE FALLABA EL RESTO DE PRUEBAS CONTEXT BEFORE
    context 'when user is signed in' do
      before do
        @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {  })
      end
      it 'shopping cart empty' do
        get '/carro/detalle'
        expect(flash[:alert]).to eq('No tienes productos que comprar.')
        expect(response).to redirect_to('/carro')
      end
    end

    context 'when user is not signed in' do
      before { sign_out @user }

      it 'redirects to the root path' do
        get '/carro/detalle'
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Debes iniciar sesión para comprar.')
      end
    end
  end

  describe 'POST /carro/insertar_producto' do
    context 'when user is signed in' do
      it 'adds a product to the shopping cart' do
        post '/carro/insertar_producto', params: { product_id: @product.id, add: { amount: 2 } }
        expect(assigns(:shopping_cart).products.size).to eq(1)
        expect(assigns(:shopping_cart).products[@product.id.to_s]).to eq(2)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is signed in' do
      before do
        post '/carro/insertar_producto', params: { product_id: @product.id, add: { amount: 15 } }
      end
      it 'does not add a product with insufficient stock' do
        expect(assigns(:shopping_cart).products[@product.id.to_s]).to eq(15)
        expect(flash[:alert]).to eq("El producto 'Test Product' no tiene suficiente stock para agregarlo al carro de compras.")
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is signed in' do
      before do
        @product2 = Product.create!(nombre: 'Test Product 1', precio: 100, stock: 102, user_id: @user.id, categories: 'Cancha')
        post '/carro/insertar_producto', params: { product_id: @product2.id, add: { amount: 101 } }
      end
      it 'max possible' do
        expect(assigns(:shopping_cart).products[@product2.id.to_s]).to eq(101)
        expect(flash[:alert]).to eq("El producto 'Test Product 1' tiene un máximo de 100 unidades por compra.")
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is signed in and cart has less than 8 products' do
      before do
        7.times do |i|
          product = Product.create!(nombre: "Test Product #{i + 1}", precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
          post '/carro/insertar_producto', params: { product_id: product.id, add: { amount: 2 } }
        end
      end
    
      it 'adds a new product to the cart' do
        new_product = Product.create!(nombre: 'New Product', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
        post '/carro/insertar_producto', params: { product_id: new_product.id, add: { amount: 2 } }
    
        expect(assigns(:shopping_cart).products.size).to eq(8)
        expect(assigns(:shopping_cart).products[new_product.id.to_s]).to eq(2)
      end
    end

    context 'when user is signed in' do
      before do
        8.times do |i|
          product = Product.create!(nombre: "Test Product #{i + 1}", precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
          post '/carro/insertar_producto', params: { product_id: product.id, add: { amount: 2 } }
        end
    
        @product9 = Product.create!(nombre: 'Test Product 9', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
        post '/carro/insertar_producto', params: { product_id: @product9.id, add: { amount: 2 } }
      end
        

      it 'too much products' do
        expect(assigns(:shopping_cart).products.size).to eq(8)

      expect(flash[:alert]).to eq('Has alcanzado el máximo de productos en el carro de compras (8). ' \
        'Elimina productos para agregar más o realiza el pago de los productos actuales.')
      expect(response).to redirect_to(root_path)
      end
    end

    context 'when user is not signed in' do
      before { sign_out @user }

      it 'redirects to the shopping cart' do
        post '/carro/insertar_producto', params: { product_id: @product.id, add: { amount: 2 } }
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('Debes iniciar sesión para agregar productos al carro de compras.')
      end
    end

    context 'when user is signed in' do
      before do
        post '/carro/comprar_ahora', params: { product_id: @product.id, add: { amount: 1 } }
      end 
      it 'redirects to details page if buy_now is true' do
        expect(response).to redirect_to('/carro/detalle')
        expect(assigns(:shopping_cart).products[@product.id.to_s]).to eq(1)
      end
    end

    context 'when there is an error updating the shopping cart' do
      before do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      end

      it 'redirects back with an error message and unprocessable entity status' do
        post '/carro/insertar_producto', params: { product_id: @product.id, add: { amount: 1 } }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('You are being <a href="http://www.example.com/">redirected</a>.')
        expect(flash[:alert]).to eq('Hubo un error al agregar el producto al carro de compras')
        
      end
    end

  end

  describe 'DELETE /carro/eliminar_producto' do
    before do
      @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
    end

    it 'removes a product from the shopping cart' do
      delete "/carro/eliminar_producto/#{@product.id}", params: { product_id: @product.id }
      expect(assigns(:shopping_cart).products).to be_empty
      expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
      expect(response).to redirect_to('/carro')
    end

    it 'tries to remove a product not in the shopping cart' do
      another_product = Product.create!(nombre: 'Another Product', precio: 50, stock: 5, user_id: @user.id, categories: 'Cancha')
      
      delete "/carro/eliminar_producto/#{another_product.id}", params: { product_id: another_product.id }
      
      expect(assigns(:shopping_cart).products).to eq({ @product.id.to_s => 1 })
      expect(flash[:alert]).to eq('El producto no existe en el carro de compras')
      expect(response).to redirect_to('/carro')
    end

    context 'when user is signed in' do
      before do
        allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
        delete "/carro/eliminar_producto/#{@product.id}", params: { product_id: @product.id }
      end
      it 'handles error when updating the shopping cart fails' do
        expect(flash[:alert]).to eq('Hubo un error al eliminar el producto del carro de compras')
        expect(response).to redirect_to('/carro')
      end
    end
  end

  describe 'POST /carro/comprar_ahora' do
    it 'adds a product to the shopping cart and redirects to details' do
      post '/carro/comprar_ahora', params: { product_id: @product.id, add: { amount: 1 } }
      expect(response).to redirect_to('/carro/detalle')
    end
  end

  describe 'POST /carro/realizar_compra' do
    context 'when the shopping cart is not found' do
      it 'redirects with an alert message' do
        post '/carro/realizar_compra'
        expect(response).to redirect_to('/carro')
        expect(flash[:alert]).to eq('No se encontró tu carro de compras. Contacte un administrador.')
      end
    end
  end

  describe 'POST /carro/realizar_compra' do
    before do
      @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
    end

    it 'completes the purchase and clears the shopping cart' do
      post '/carro/realizar_compra'
      expect(assigns(:shopping_cart).products).to be_empty
      expect(flash[:notice]).to eq('Compra realizada exitosamente')
    end

    it 'fails to complete the purchase if stock is insufficient' do
      @product.update(stock: 0)
      post '/carro/realizar_compra'
      expect(flash[:alert]).to eq("Compra cancelada: El producto '#{@product.nombre}' no tiene suficiente stock para realizar la compra. Por favor, elimina el producto del carro de compras o reduce la cantidad.")
      expect(response).to redirect_to('/carro')
    end

    it 'redirects with an alert message if cart update fails' do
      allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      
      post '/carro/realizar_compra'
      expect(response).to redirect_to('/carro')
      expect(flash[:alert]).to eq('Hubo un error al actualizar el carro. Contacte un administrador.')
    end
  end

  context 'when the shopping cart is empty' do
    before do
      @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: {})
    end

    it 'redirects with an alert message' do
      post '/carro/realizar_compra'
      expect(response).to redirect_to('/carro')
      expect(flash[:alert]).to eq('No tienes productos en el carro de compras')
    end
  end

  describe 'DELETE /carro/limpiar' do
    before do
      @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
    end

    it 'clears the shopping cart' do
      delete '/carro/limpiar'
      expect(assigns(:shopping_cart).products).to be_empty
      expect(flash[:notice]).to eq('Carro de compras limpiado exitosamente')
      expect(response).to redirect_to('/carro')
    end

    it 'redirects with an alert message if cart update fails' do
      allow_any_instance_of(ShoppingCart).to receive(:update).and_return(false)
      
      delete '/carro/limpiar'
      expect(response).to redirect_to('/carro')
      expect(flash[:alert]).to eq('Hubo un error al limpiar el carro de compras. Contacte un administrador.')
    end
  end
end
