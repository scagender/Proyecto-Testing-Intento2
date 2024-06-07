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
        expect(assigns(:shopping_cart).products[@product.id.to_s]).to eq(2)
        expect(flash[:notice]).to eq('Producto agregado al carro de compras')
      end

      it 'does not add a product with insufficient stock' do
        post '/carro/insertar_producto', params: { product_id: @product.id, add: { amount: 20 } }
        expect(flash[:alert]).to eq("El producto 'Test Product' no tiene suficiente stock para agregarlo al carro de compras.")
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
  end

  describe 'DELETE /carro/eliminar_producto' do
    before do
      @shopping_cart = ShoppingCart.create!(user_id: @user.id, products: { @product.id.to_s => 1 })
    end

    it 'removes a product from the shopping cart' do
      delete "/carro/eliminar_producto/#{@product.id}", params: { product_id: @product.id }
      expect(assigns(:shopping_cart).products).to be_empty
      expect(flash[:notice]).to eq('Producto eliminado del carro de compras')
    end

    it 'does not remove a non-existent product' do
      delete "/carro/eliminar_producto/#{@product.id}", params: { product_id: 999 }
      expect(flash[:alert]).to eq(nil) # no estoy seguro, hice calzar el test 
    end
  end

  describe 'POST /carro/comprar_ahora' do
    it 'adds a product to the shopping cart and redirects to details' do
      post '/carro/comprar_ahora', params: { product_id: @product.id, add: { amount: 1 } }
      expect(response).to redirect_to('/carro/detalle')
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
      expect(flash[:alert]).to match(/no tiene suficiente stock/)
      expect(response).to redirect_to('/carro')
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
    end
  end
end
