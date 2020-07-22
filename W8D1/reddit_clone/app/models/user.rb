class User < ApplicationRecord
    validates :username, presence:true, uniqueness:true
    validates :password_digest, presence:true
    validates :password, length: { minimum: 6, allow_nil:true }

    attr_reader :password

    after_initialize :ensure_session_token

    has_many :subs,
        foreign_key: :user_id,
        class_name: :Sub
      
    has_many :posts,
      foreign_key: :author_id,
      class_name: :Post

    def password=(password)
      @password = password
      self.password_digest = BCrypt::Password.create(password)
    end

    def ensure_session_token
      self.session_token ||= SecureRandom::urlsafe_base64
    end

    def reset_session_token!
      self.session_token = SecureRandom::urlsafe_base64
      self.save!
      self.session_token
    end

    def check_password(password)
      password_obj = BCrypt::Password.new(self.password_digest)
      password_obj.is_password?(password)
    end

    def self.find_by_credentials(username, password)
      user = User.find_by(username: username)

      if user && user.check_password(password)
        user
      else
        nil
      end
    end

end
