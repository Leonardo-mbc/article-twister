class User < ActiveRecord::Base
  has_many :user_discriminations
  has_many :recommendations

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :twitter]

    def self.find_for_oauth(auth)
        user = User.where(uid: auth.uid, provider: auth.provider).first

        email = auth.info.email
        email = self.dummy_email auth if email.nil?

        unless user
            user = User.create(
                uid:      auth.uid,
                provider: auth.provider,
                email:    email,
                name:     auth.info.name,
                password: Devise.friendly_token[0, 20]
            )
        end

        user
    end

    private

    def self.dummy_email(auth)
        "#{auth.uid}-#{auth.provider}@example.com"
    end
end
