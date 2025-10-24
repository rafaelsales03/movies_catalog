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

# Criar tags de exemplo
tags_list = [
  "Clássico",
  "Baseado em fatos reais",
  "Cult",
  "Premiado",
  "Oscar",
  "Independente",
  "Blockbuster",
  "Adaptação literária",
  "Mindfuck",
  "Nostalgia",
  "Década de 80",
  "Década de 90",
  "Remake",
  "Sequência",
  "Trilogia",
  "Marvel",
  "DC",
  "Anime",
  "Musical",
  "Biográfico"
]

puts "\nCriando tags..."
tags_list.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
  print "."
end

puts "\n✅ #{Tag.count} tags criadas com sucesso!"

if Rails.env.development?
  puts "\nCriando usuário de exemplo..."
  user = User.find_or_create_by!(email: "exemplo@teste.com") do |u|
    u.password = "123456"
    u.password_confirmation = "123456"
    u.name = "Usuário de Exemplo"
  end
  puts "✅ Usuário criado: #{user.email} (senha: 123456)"

  if Movie.count == 0
    puts "\nCriando filmes de exemplo com tags..."

    movie1 = user.movies.create!(
      title: "Matrix",
      synopsis: "Um hacker descobre a verdadeira natureza da realidade.",
      year: 1999,
      duration: 136,
      director: "Lana e Lilly Wachowski",
      tag_list: "Clássico, Cult, Mindfuck, Década de 90, Trilogia"
    )
    movie1.categories << Category.find_by(name: "Ficção Científica")
    movie1.categories << Category.find_by(name: "Ação")

    movie2 = user.movies.create!(
      title: "O Poderoso Chefão",
      synopsis: "A saga da família Corleone no mundo do crime organizado.",
      year: 1972,
      duration: 175,
      director: "Francis Ford Coppola",
      tag_list: "Clássico, Premiado, Oscar, Trilogia"
    )
    movie2.categories << Category.find_by(name: "Drama")
    movie2.categories << Category.find_by(name: "Crime")

    movie3 = user.movies.create!(
      title: "Toy Story",
      synopsis: "A vida secreta dos brinquedos quando não estão sendo observados.",
      year: 1995,
      duration: 81,
      director: "John Lasseter",
      tag_list: "Clássico, Década de 90, Nostalgia, Trilogia"
    )
    movie3.categories << Category.find_by(name: "Animação")
    movie3.categories << Category.find_by(name: "Aventura")
    movie3.categories << Category.find_by(name: "Comédia")

    movie4 = user.movies.create!(
      title: "O Rei Leão",
      synopsis: "Um jovem leão deve assumir seu lugar como rei da savana.",
      year: 1994,
      duration: 88,
      director: "Roger Allers",
      tag_list: "Clássico, Musical, Década de 90, Nostalgia, Remake"
    )
    movie4.categories << Category.find_by(name: "Animação")
    movie4.categories << Category.find_by(name: "Musical")

    movie5 = user.movies.create!(
      title: "Clube da Luta",
      synopsis: "Um funcionário de escritório insone forma um clube underground.",
      year: 1999,
      duration: 139,
      director: "David Fincher",
      tag_list: "Cult, Mindfuck, Adaptação literária, Década de 90"
    )
    movie5.categories << Category.find_by(name: "Drama")
    movie5.categories << Category.find_by(name: "Thriller")

    movie6 = user.movies.create!(
      title: "Vingadores: Ultimato",
      synopsis: "Os heróis restantes se unem para reverter as ações de Thanos.",
      year: 2019,
      duration: 181,
      director: "Anthony e Joe Russo",
      tag_list: "Blockbuster, Marvel, Sequência"
    )
    movie6.categories << Category.find_by(name: "Ação")
    movie6.categories << Category.find_by(name: "Ficção Científica")

    puts "✅ #{Movie.count} filmes de exemplo criados com tags!"
  end
end

puts "\n🎉 Seeds executados com sucesso!"
