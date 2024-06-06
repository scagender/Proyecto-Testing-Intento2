
require 'rails_helper'

RSpec.describe ContactMessage, type: :model do
  before(:each) do
    @contact_message = ContactMessage.new(
      title: 'Prueba',
      body: 'Muy buenos productos ofreces, tienes ig?.',
      name: 'Juan Pablo',
      mail: 'juanpablo@example.com',
      phone: '+56978767654'
    )
  end

  describe "Validations" do
    it 'is valid with valid attributes' do
      expect(@contact_message).to be_valid
    end

    it 'is not valid without a title' do
      @contact_message.title = nil
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with a title longer than 50 characters' do
      @contact_message.title = 'a' * 51
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid without a body' do
      @contact_message.body = nil
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with a body longer than 500 characters' do
      @contact_message.body = 'a' * 501
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid without a name' do
      @contact_message.name = nil
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with a name longer than 50 characters' do
      @contact_message.name = 'a' * 51
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid without a mail' do
      @contact_message.mail = nil
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with an invalid mail' do
      @contact_message.mail = 'invalid_email'
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with a mail longer than 50 characters' do
      @contact_message.mail = 'a' * 51 + '@example.com'
      expect(@contact_message).to_not be_valid
    end

    it 'is valid without a phone' do
      @contact_message.phone = nil
      expect(@contact_message).to be_valid
    end

    it 'is not valid with a phone longer than 20 characters' do
      @contact_message.phone = '+5691234567890123456789'
      expect(@contact_message).to_not be_valid
    end

    it 'is not valid with an invalid phone format' do
      @contact_message.phone = '12345'
      expect(@contact_message).to_not be_valid
    end

    it 'is valid with a correctly formatted phone' do
      @contact_message.phone = '+56912345678'
      expect(@contact_message).to be_valid
    end

    it 'is valid with a black phone' do
      @contact_message.phone = ''
      expect(@contact_message).to be_valid
    end

    it 'is valid with a null phone' do
      @contact_message.phone = nil
      expect(@contact_message).to be_valid
    end
  end
end