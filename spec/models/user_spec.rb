require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:username) }

    it { should validate_uniqueness_of(:username) }
  end

  describe 'user creation' do
    let(:user) { create(:user, username: 'wat_user') }

    it { expect(user.admin?).to be_falsey }
    it { expect(user.banned_at).to be_nil }
  end

  describe 'scopes' do
    describe '.by_username' do
      it 'finds users regardless of the case passed' do
        camel_user = create(:user, username: 'CaMeLcAsEd')
        upper_user = create(:user, username: 'UPPERCASE')

        result = described_class.by_username(%w[CAMELCASED uppercase])

        expect(result).to contain_exactly(camel_user, upper_user)
      end

      it 'finds a single user regardless of the case passed' do
        user = create(:user, username: 'CaMeLcAsEd')

        expect(described_class.by_username('CAMELCASED')).to contain_exactly(user)
      end
    end

    describe '.admins' do
      let!(:user) { create(:user) }

      it 'returns only user with admin privileges' do
        admin = create(:admin)

        expect(described_class.admins).to eq([admin])
      end

      it 'returns nothing if admins not present' do
        expect(described_class.admins).to eq([])
      end
    end

    describe '.banned' do
      let!(:user) { create(:user) }

      it 'returns only banned users' do
        banned_user = create(:user, banned_at: Time.now)

        expect(described_class.banned).to eq([banned_user])
      end

      it 'returns nothing if banned user not present' do
        expect(described_class.banned).to eq([])
      end
    end

    describe '.active' do
      let!(:banned_user) { create(:user, banned_at: Time.now) }

      it 'returns only active users' do
        active_user = create(:user)

        expect(described_class.active).to eq([active_user])
      end

      it 'returns nothing if active user not present' do
        expect(described_class.active).to eq([])
      end
    end

    describe '.confirmed' do
      let!(:unconfirmed_user) { create(:user, confirmed_at: nil) }

      it 'returns only user confirmed users' do
        user = create(:user)

        expect(described_class.confirmed).to eq([user])
      end

      it 'returns nothing if confirmed user not present' do
        expect(described_class.confirmed).to eq([])
      end
    end
  end

  describe '.filter' do
    let(:user) { double }

    it 'filters by active users by default' do
      expect(described_class).to receive(:active).and_return([user])

      expect(described_class.filter(nil)).to include(user)
    end

    it 'filters by admins' do
      expect(described_class).to receive(:admins).and_return([user])

      expect(described_class.filter('admins')).to include(user)
    end

    it 'filters by banned' do
      expect(described_class).to receive(:banned).and_return([user])

      expect(described_class.filter('banned')).to include(user)
    end
  end

  describe '.find_for_database_authentication' do
    it 'strips whitespace from login' do
      user = create(:user)

      expect(described_class.find_for_database_authentication(login: " #{user.username} ")).to eq user
    end
  end

  describe '.by_login' do
    let(:username) { 'John' }
    let!(:user) { create(:user, username: username) }

    it 'finds user by email' do
      expect(described_class.by_login(user.email)).to eq(user)
    end

    it 'finds user by upcase email match' do
      expect(described_class.by_login(user.email.upcase)).to eq(user)
    end

    it 'finds user by username match' do
      expect(described_class.by_login(username)).to eq (user)
    end

    it 'finds user by username lowercase' do
      expect(described_class.by_login(username.downcase)).to eq(user)
    end

    it 'returns nil on nil login' do
      expect(described_class.by_login(nil)).to be_nil
    end

    it 'returns nil on empty login string' do
      expect(described_class.by_login('')).to be_nil
    end
  end

  describe '.find_by_username' do
    it 'returns nil if not found' do
      expect(described_class.find_by_username('JohnDoe')).to be_nil
    end

    it 'is case-insensitive' do
      user = create(:user, username: 'JohnDoe')

      expect(described_class.find_by_username('JOHNDOE')).to eq(user)
    end
  end

  describe '.find_by_username!' do
    it 'raises RecordNotFound' do
      expect { described_class.find_by_username!('JohnDoe') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'is case-insensitive' do
      user = create(:user, username: 'JohnDoe')

      expect(described_class.find_by_username!('JOHNDOE')).to eq user
    end
  end

  describe '.where_not_in' do
    context 'without an argument' do
      it 'returns the current relation' do
        user = create(:user)

        expect(described_class.where_not_in).to eq([user])
      end
    end

    context 'using a list of user IDs' do
      it 'excludes the users from the returned relation' do
        user1 = create(:user)
        user2 = create(:user)

        expect(described_class.where_not_in([user2.id])).to eq([user1])
      end
    end
  end
end