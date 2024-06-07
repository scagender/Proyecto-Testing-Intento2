require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @admin = User.create!(name: 'Usuario Admin', password: 'Ejemplo123!', email: 'admin5@gmail.com', role: 'admin')
    @user = User.create!(name: 'Usuario Regular', password: 'Ejemplo123!', email: 'user3@gmail.com', role: 'user')
    sign_in @admin
    @product = Product.create!(nombre: 'Producto 1', precio: 4000, stock: 1, user_id: @admin.id, categories: 'Cancha')
  end

  # GOD  
  describe 'GET /products/index' do
    it 'returns http success for authenticated user' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    # GOD
    it 'returns http success for unauthenticated user' do
      sign_out @admin
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
  end


  describe 'POST /products/insertar' do
    let(:valid_attributes) { { nombre: 'NuevoProducto', precio: 5000, stock: 10, categories: 'Cancha' } }
    let(:invalid_attributes) { { nombre: '', precio: nil, stock: nil, categories: '' } }

    # GOD
    context 'with valid parameters' do
      it 'creates a new Product' do
        expect {
          post '/products/insertar', params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
        expect(flash[:notice]).to match(/Producto creado Correctamente !/)
        expect(response).to redirect_to('/products/index')
      end
    end

    # GOD
    context 'with invalid parameters' do
      it 'does not create a new Product' do
        expect {
          post '/products/insertar', params: { product: invalid_attributes }
        }.to change(Product, :count).by(0)
        expect(flash[:error]).to match(/Hubo un error al guardar el producto:/)
        expect(response).to redirect_to('/products/crear')
      end
    end

    
    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      # GOD
      it 'does not allow creation of a product' do
        expect {
          post '/products/insertar', params: { product: valid_attributes }
        }.to change(Product, :count).by(0)
        expect(flash[:alert]).to match(/Debes ser un administrador para crear un producto./)
        expect(response).to redirect_to('/products/index')
      end
    end
  end

  describe 'PATCH /products/actualizar/:id' do
    let(:new_attributes) { { nombre: 'ProductoActualizado' } }

    context 'with valid parameters' do
      it 'updates the requested product' do
        patch "/products/actualizar/#{@product.id}", params: { product: new_attributes }
        @product.reload
        expect(@product.nombre).to eq('ProductoActualizado')
        expect(response).to redirect_to('/products/index')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the product' do
        patch "/products/actualizar/#{@product.id}", params: { product: { nombre: '' } }
        @product.reload
        expect(@product.nombre).not_to eq('')
        expect(flash[:error]).to match(/Hubo un error al guardar el producto./)
        expect(response).to redirect_to("/products/actualizar/#{@product.id}")
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'does not allow updating a product' do
        patch "/products/actualizar/#{@product.id}", params: { product: new_attributes }
        @product.reload
        expect(@product.nombre).not_to eq('ProductoActualizado')
        expect(flash[:alert]).to match(/No estás autorizado para acceder a esta página/)
        expect(response).to redirect_to('/')
      end
    end
  end

  describe 'DELETE /products/eliminar/:id' do
    context 'as an admin' do
      it 'deletes the product' do
        product_to_delete = Product.create!(nombre: 'ProductoAEliminar', precio: 5000, stock: 5, user_id: @admin.id, categories: 'Cancha')
        expect {
          delete "/products/eliminar/#{product_to_delete.id}"
        }.to change(Product, :count).by(-1)
        expect(response).to redirect_to('/products/index')
      end

    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'does not allow deletion of the product' do
        product_to_delete = Product.create!(nombre: 'ProductoAEliminar', precio: 5000, stock: 5, user_id: @admin.id, categories: 'Cancha')
        expect {
          delete "/products/eliminar/#{product_to_delete.id}"
        }.to change(Product, :count).by(0)
        expect(flash[:alert]).to match(/No estás autorizado para acceder a esta página/)
        expect(response).to redirect_to('/')
      end
    end
  end

  describe 'POST products/insert_deseado/:product_id' do
    context 'when the wishlist is empty' do
      it 'adds the product to the wishlist' do
        expect(@admin.deseados).to eq([])

        post "/products/insert_deseado/#{@product.id}"

        @admin.reload
        expect(@admin.deseados).to include(@product.id.to_s)
        expect(flash[:notice]).to match(/Producto agregado a la lista de deseados/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'when the wishlist already has products' do
      before do
        @admin.update(deseados: ['1', '2'])
      end

      it 'adds the new product to the existing wishlist' do
        post "/products/insert_deseado/#{@product.id}"

        @admin.reload
        expect(@admin.deseados).to include('1', '2', @product.id.to_s)
        expect(flash[:notice]).to match(/Producto agregado a la lista de deseados/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'when the user cannot be saved' do
      before do
        allow_any_instance_of(User).to receive(:save).and_return(false)
        @admin.update(deseados: ['1', '2'])
      end

      it 'does not add the product and shows an error message' do
        post "/products/insert_deseado/#{@product.id}"

        @admin.reload
        expect(@admin.deseados).to eq(['1', '2']) # The wishlist should remain unchanged
        expect(flash[:error]).to match(/Hubo un error al guardar los cambios:/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end
end
