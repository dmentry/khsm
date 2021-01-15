require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для игрового контроллера
# Самые важные здесь тесты:
#   1. на авторизацию (чтобы к чужим юзерам не утекли не их данные)
#   2. на четкое выполнение самых важных сценариев (требований) приложения
#   3. на передачу граничных/неправильных данных в попытке сломать контроллер
#
RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions_for_controller) { FactoryBot.create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  context 'Anon' do
    # из экшена show анона посылаем
    it 'kick from #show' do
      # вызываем экшен
      get :show, id: game_w_questions_for_controller.id
      # проверяем ответ
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    #Домашка 61-4 Анонимный посетитель не может вызвать действия контроллера
    it 'can not #create' do
      post :create

      game = assigns(:game)

      expect(game).to be_nil

      expect(response).to redirect_to(new_user_session_path)

      expect(flash[:alert]).to be
    end

    it 'can not #answer' do
      put :answer, id: game_w_questions_for_controller.id, letter: game_w_questions_for_controller.current_game_question.correct_answer_key

      game = assigns(:game)

      expect(game).to be_nil

      expect(response).to redirect_to(new_user_session_path)

      expect(flash[:alert]).to be
    end

    it 'can not #take_money' do
      put :take_money, id: game_w_questions_for_controller.id

      game = assigns(:game)

      expect(game).to be_nil

      expect(response).not_to redirect_to(user_path(user))

      expect(response).to redirect_to(new_user_session_path)

      expect(flash[:alert]).to be
    end

    it 'can not use #help' do
      put :help, id: game_w_questions_for_controller.id

      game = assigns(:game)

      expect(game).to be_nil

      expect(response).not_to redirect_to(game_path(game_w_questions_for_controller))

      expect(response).to redirect_to(new_user_session_path)

      expect(flash[:alert]).to be
    end

  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'Usual user' do
    # перед каждым тестом в группе
    before(:each) { sign_in user } # логиним юзера user с помощью спец. Devise метода sign_in

    # юзер может создать новую игру
    it 'creates game' do
      # сперва накидаем вопросов, из чего собирать новую игру
      generate_questions(15)

      post :create
      game = assigns(:game) # вытаскиваем из контроллера поле @game

      # проверяем состояние этой игры
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)
      # и редирект на страницу этой игры
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    # юзер видит свою игру
    it '#show game' do
      get :show, id: game_w_questions_for_controller.id
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200) # должен быть ответ HTTP 200
      expect(response).to render_template('show') # и отрендерить шаблон show
    end

    # юзер отвечает на игру корректно - игра продолжается
    it 'answers correct' do
      # передаем параметр params[:letter]
      put :answer, id: game_w_questions_for_controller.id, letter: game_w_questions_for_controller.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy # удачный ответ не заполняет flash
    end

    #Домашка 61-1 Юзер не видит чужую игру
    it '#show game' do
      game2_w_questions_for_controller = FactoryBot.build(:game_with_questions)

      get :show, id: game2_w_questions_for_controller.id

      expect(response.status).not_to eq(200) # не должен быть ответ HTTP 200 ОК

      expect(response).to redirect_to(root_path)

      expect(flash[:alert]).to be
    end

    #Домашка 61-2 #take_money
    it '#take_money' do
      q = game_w_questions_for_controller.current_game_question

      game_w_questions_for_controller.answer_current_question!(q.correct_answer_key)

      game_w_questions_for_controller.take_money!

      prize = game_w_questions_for_controller.prize

      expect(prize).to be > 0

      put :take_money, id: game_w_questions_for_controller.id

      game = assigns(:game)

      expect(game.finished?).to be_truthy

      expect(game.prize).to eq(100)

      # пользователь изменился в базе, надо в коде перезагрузить!
      user.reload

      expect(user.balance).to eq(100)

      expect(response).to redirect_to(user_path(user))

      expect(flash[:alert]).to be
    end

    #Домашка 61-3 пользователь не может начать две игры
    it 'redirect to the one and only game' do
      # убедились что есть игра в работе
      expect(game_w_questions_for_controller.finished?).to be_falsey

      # отправляем запрос на создание, убеждаемся что новых Game не создалось
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game).to be_nil

      # и редирект на страницу старой игры
      expect(response).to redirect_to(game_path(game_w_questions_for_controller))
      expect(flash[:alert]).to be
    end

    #Домашка 61-5 #answer случай "неправильный ответ игрока"
    it 'how #answer acts if incorrect variant' do
      game_w_questions_for_controller.update_attribute(:current_level, 6)

      q = game_w_questions_for_controller.current_game_question

      correct_answer = q.correct_answer_key

      not_correct_answer = %w[a b c d].detect { |element| element != correct_answer }

      put :answer, id: game_w_questions_for_controller.id, letter: not_correct_answer

      game = assigns(:game)

      expect(game.finished?).to be_truthy

      expect(flash[:alert]).to be

      expect(game.status).to eq(:fail)

      expect(game.prize).to eq(1000)
    end
  end
end
