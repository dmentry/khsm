require 'rails_helper'

# Тест на шаблон users/show.html.erb
RSpec.describe 'users/show', type: :view do
  let(:game) { FactoryBot.create(:game, id: 15, created_at: Time.parse('2016.10.09, 13:00'), current_level: 10, prize: 1000) }

  context 'Anon user' do
    before(:each) do
      assign(:user, FactoryBot.build_stubbed(:user, name: 'Вадик', balance: 5000))

      render
    end

    it 'renders player name' do
      expect(rendered).to match 'Вадик'
    end

    it 'renders player name' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end

  context 'Logged-in user' do
    before(:each) do
      user = FactoryBot.create(:user, name: 'Вадик', balance: 5000)

      sign_in user

      assign(:user, user)

      assign(:game, game)
    end

    it 'shows player name' do
      render

      expect(rendered).to match 'Вадик'
    end

    it 'shows password change option' do
      render

      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'shows game elements' do
      render partial: 'users/game', object: game

      expect(rendered).to match '15'

      expect(rendered).to match '09 окт., 13:00'
    end
  end
end