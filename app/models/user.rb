class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :preferred_language, class_name: "Language", optional: true
  belongs_to :native_language, class_name: "Language", optional: true

  has_many :collections, dependent: :destroy
  has_many :cards, dependent: :destroy
end
