require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @admin = User.create!(name: 'AdminUser', password: 'Nonono123!', email: 'admin@gmail.com', role: 'admin')
    @user = User.create!(name: 'RegularUser', password: 'Nonono123!', email: 'user@gmail.com', role: 'user')
    sign_in @admin
    @product = Product.create!(nombre: 'Producto1', precio: 4000, stock: 1, user_id: @admin.id, categories: 'Cancha')
  end

  describe 'GET /products/index' do
    it 'returns http success for authenticated user' do
      get '/products/index'
      expect(response).to have_http_status(:success)
    end

    it 'returns http success for unauthenticated user' do
      sign_out @admin
      get '/products/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /products/insertar' do
    let(:valid_attributes) { { nombre: 'NuevoProducto', precio: 5000, stock: 10, categories: 'Cancha' } }
    let(:invalid_attributes) { { nombre: '', precio: nil, stock: nil, categories: '' } }

    context 'with valid parameters' do
      it 'creates a new Product' do
        expect {
          post '/products/insertar', params: { product: valid_attributes }
        }.to change(Product, :count).by(1)
        expect(flash[:notice]).to match(/Producto creado Correctamente !/)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Product' do
        expect {
          post '/products/insertar', params: { product: invalid_attributes }
        }.to change(Product, :count).by(0)
        expect(flash[:error]).to match(/Hubo un error al guardar el producto:/)
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

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
        # expect(flash[:alert]).to match(/Debes ser un administrador para modificar un producto./)
        expect(response).to redirect_to('/products/index')
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
        # expect(flash[:alert]).to match(/Debes ser un administrador para eliminar un producto./)
        expect(response).to redirect_to('/products/index')
      end
    end
  end
end
