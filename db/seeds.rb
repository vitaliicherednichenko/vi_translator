languages = [
  { name: "English", code: "en", native_name: "English" },
  { name: "Spanish", code: "es", native_name: "Español" },
  { name: "French", code: "fr", native_name: "Français" },
  { name: "German", code: "de", native_name: "Deutsch" },
  { name: "Italian", code: "it", native_name: "Italiano" },
  { name: "Portuguese", code: "pt", native_name: "Português" },
  { name: "Russian", code: "ru", native_name: "Русский" },
  { name: "Japanese", code: "ja", native_name: "日本語" },
  { name: "Chinese", code: "zh", native_name: "中文" },
  { name: "Korean", code: "ko", native_name: "한국어" },
  { name: "Arabic", code: "ar", native_name: "العربية" },
  { name: "Hindi", code: "hi", native_name: "हिन्दी" },
  { name: "Ukrainian", code: "uk", native_name: "Українська" }
]

languages.each do |attrs|
  Language.find_or_create_by!(code: attrs[:code]) do |lang|
    lang.assign_attributes(attrs)
  end
end

puts "Seeded #{Language.count} languages"

admin_email = "vitaliy.cherednichenko113@gmail.com"
if (admin = User.find_by(email: admin_email))
  admin.update!(admin: true)
  puts "Granted admin to #{admin_email}"
else
  puts "User #{admin_email} not found — sign up first, then re-run `bin/rails db:seed`"
end
