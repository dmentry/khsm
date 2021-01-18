# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса, в идеале весь наш функционал
# (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do
  # Задаем локальную переменную game_question, доступную во всех тестах этого
  # сценария: она будет создана на фабрике заново для каждого блока it,
  # где она вызывается.
  let(:game_question) do
    FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3)
  end

  # Группа тестов на игровые методы
  context 'game methods' do

    # Тест на правильную генерацию хэша с вариантами
    describe '#variants' do
      it 'correct variants are put in hash' do
        expect(game_question.variants).to eq(
          'a' => game_question.question.answer2,
          'b' => game_question.question.answer1,
          'c' => game_question.question.answer4,
          'd' => game_question.question.answer3
        )
      end
    end

    describe '#answer_correct?' do
      it 'should choose correct variant' do

        # Именно под буквой b в тесте мы спрятали указатель на верный ответ
        expect(game_question.answer_correct?('b')).to be true
      end
    end

    #Домашка 60-2 корректность методов делегирования level и text
    it 'present methods: text and level correctly' do
      expect(game_question.text).to eq(game_question.question.text)

      expect(game_question.level).to eq(game_question.question.level)
    end

    #Домашка 60-5 метод correct_answer_key
    describe '#correct_answer_key' do
      it 'should return right letter' do
        expect(game_question.correct_answer_key).to eq('b')
      end
    end
  end

  #Домашка 62-1 #help_hash
  describe '#help_hash' do
    it 'should have appropriate content' do
      expect(game_question.help_hash).to eq({})

    # добавляем пару ключей
    game_question.help_hash[:some_key1] = 'blabla1'
    game_question.help_hash['some_key2'] = 'blabla2'

    expect(game_question.save).to be_truthy

    # загрузим этот же вопрос из базы для чистоты эксперимента
    gq = GameQuestion.find(game_question.id)

    # проверяем новые значение хэша
    expect(gq.help_hash).to eq({some_key1: 'blabla1', 'some_key2' => 'blabla2'})
    end
  end

  context 'user helpers' do
    describe '#audience_help' do
      it 'correct audience_help consisting' do
        # Проверяем, что объект не включает эту подсказку
        expect(game_question.help_hash).not_to include(:audience_help)

        # Добавили подсказку
        game_question.add_audience_help

        # Ожидаем, что в хеше появилась подсказка
        expect(game_question.help_hash).to include(:audience_help)

        # Дёргаем хеш
        ah = game_question.help_hash[:audience_help]
        # Проверяем, что входят только ключи a, b, c, d
        expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end
  end

  #Домашка 62-2 #fifty_fifty
  describe '#fifty_fifty' do
    it 'should return 2 variants' do
      expect(game_question.help_hash).not_to include(:fifty_fifty)

      game_question.add_fifty_fifty

      expect(game_question.help_hash).to include(:fifty_fifty)

      ff = game_question.help_hash[:fifty_fifty]

      expect(ff).to include('b')

      expect(ff.size).to eq(2)
    end
  end

  #Домашка 62-3 #friend_call
  describe '#friend_call' do
    it 'should return text with opinion' do
      expect(game_question.help_hash).not_to include(:friend_call)

      game_question.add_friend_call

      expect(game_question.help_hash).to include(:friend_call)

      fc = game_question.help_hash[:friend_call]

      expect(fc).to include('считает')
    end
  end
end