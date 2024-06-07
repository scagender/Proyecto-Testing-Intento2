require 'rails_helper'

RSpec.describe 'Products', type: :request do
  before do
    @admin = User.create!(name: 'Usuario Admin', password: 'Ejemplo123!', email: 'admin5@gmail.com', role: 'admin')
    @user = User.create!(name: 'Usuario Regular', password: 'Ejemplo123!', email: 'user3@gmail.com', role: 'user')
    @user2 = User.new(name: 'Usuario Regular 2', password: 'Ejemplo123!', email: 'user9@gmail.com', role: 'user')
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
      end

      it 'does not add the product and shows an error message' do
        post "/products/insert_deseado/#{@product.id}"

        expect(@admin.reload.deseados).to eq([])
        expect(flash[:error]).to match(/Hubo un error al guardar los cambios:/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end

  describe 'GET #leer' do
    @review = Review.create(tittle: 'Great Product', description: 'This is a great product', calification: 5, user: @user, product: @product)
    @message = Message.new(body: 'Este es un mensaje de prueba', user: @admin, product: @product)

    before do
      allow(JokeApiService).to receive(:fetch_joke).and_return('This is a joke')
      get "/products/leer/#{@product.id}"
    end

    it 'assigns @joke' do
      expect(assigns(:joke)).to eq('This is a joke')
    end

    it 'assigns @product' do
      expect(assigns(:product)).to eq(@product)
    end

    it 'assigns @messages' do
      expect(assigns(:messages)).to match_array(@message)
    end

    it 'assigns @reviews' do
      expect(assigns(:reviews)).to match_array(@review)
    end

    it 'calculates @calification' do
      expect(assigns(:calification_mean)).to eq(5)
    end

    it 'allows nil calification' do
      expect(assigns(:calification_mean)).to eq(nil)
    end

    it 'doesnt have horarios' do
      expect(assigns(:horarios)).to be_nil
    end

    it 'assigns @horarios correctly' do
      @product2 = Product.create!(nombre: 'Producto 2', precio: 4000, stock: 1, user_id: @admin.id, categories: 'Cancha', horarios: 'Lunes,10:00-12:00;Martes,14:00-16:00')
      get "/products/leer/#{@product2.id}"
      expect(assigns(:horarios)).to eq([['Lunes', '10:00-12:00'], ['Martes', '14:00-16:00']])
    end

    context 'when there are no reviews' do
      it 'sets @calification_mean to nil' do
        expect(assigns(:calification_mean)).to be_nil
      end
    end

  end
end
