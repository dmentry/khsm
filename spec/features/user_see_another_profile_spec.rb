require 'rails_helper'

# Начинаем описывать функционал, связанный с созданием игры
RSpec.feature 'USER see another profile', type: :feature do
  let(:user) { FactoryBot.create(:user, name: 'Юзер', balance: 5000) }

  let!(:game) { FactoryBot.create(:game, created_at: Time.parse('2016.10.09, 13:00'), finished_at: Time.parse('2016.10.09, 13:10'), is_failed: true, current_level: 10, prize: 1000, user: user) }

  let!(:game2) { FactoryBot.create(:game, created_at: Time.parse('2017.02.05, 10:00'), current_level: 5, prize: 500, user: user) }

  let(:user2) { FactoryBot.create(:user, name: 'Юзер2', balance: 2000) }

  # Перед началом любого сценария нам надо авторизовать пользователя
  before(:each) do
    login_as user2
  end

  # Сценарий успешного просмотра чужого профиля
  scenario 'successfully' do
    visit '/'

    visit '/users/1'

    expect(page).not_to have_content('Сменить имя и пароль')

    # первая игра
    expect(page).to have_content('в процессе')

    expect(page).to have_content('05 февр., 10:00')

    expect(page).to have_content('500 ₽')

    # вторая игра
    expect(page).to have_content('проигрыш')

    # expect(page).to have_content('проигрыш')

    expect(page).to have_content('09 окт., 13:00')

    expect(page).to have_content('1 000 ₽')
  end
end
