# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

categories_list = [
  "Ação",
  "Aventura",
  "Animação",
  "Comédia",
  "Crime",
  "Documentário",
  "Drama",
  "Fantasia",
  "Ficção Científica",
  "Guerra",
  "História",
  "Musical",
  "Mistério",
  "Romance",
  "Suspense",
  "Terror",
  "Thriller",
  "Western"
]

puts "Criando categorias..."
categories_list.each do |category_name|
  Category.find_or_create_by!(name: category_name)
  print "."
end

puts "\n✅ #{Category.count} categorias criadas com sucesso!"

if Rails.env.development?
  puts "\nCriando usuário de exemplo..."
  user = User.find_or_create_by!(email: "exemplo@teste.com") do |u|
    u.password = "123456"
    u.password_confirmation = "123456"
    u.name = "Usuário de Exemplo"
  end
  puts "✅ Usuário criado: #{user.email} (senha: 123456)"
  
  if Movie.count == 0
    puts "\nCriando filmes de exemplo..."
    
    movie1 = user.movies.create!(
      title: "Matrix",
      synopsis: "Um hacker descobre a verdadeira natureza da realidade.",
      year: 1999,
      duration: 136,
      director: "Lana e Lilly Wachowski"
    )
    movie1.categories << Category.find_by(name: "Ficção Científica")
    movie1.categories << Category.find_by(name: "Ação")
    
    movie2 = user.movies.create!(
      title: "O Poderoso Chefão",
      synopsis: "A saga da família Corleone no mundo do crime organizado.",
      year: 1972,
      duration: 175,
      director: "Francis Ford Coppola"
    )
    movie2.categories << Category.find_by(name: "Drama")
    movie2.categories << Category.find_by(name: "Crime")
    
    movie3 = user.movies.create!(
      title: "Toy Story",
      synopsis: "A vida secreta dos brinquedos quando não estão sendo observados.",
      year: 1995,
      duration: 81,
      director: "John Lasseter"
    )
    movie3.categories << Category.find_by(name: "Animação")
    movie3.categories << Category.find_by(name: "Aventura")
    movie3.categories << Category.find_by(name: "Comédia")
    
    puts "✅ #{Movie.count} filmes de exemplo criados!"
  end
end

puts "\n🎉 Seeds executados com sucesso!"