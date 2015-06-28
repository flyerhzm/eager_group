post1 = Post.create(title: "First post!")
post2 = Post.create(title: "Second post!")

post1.comments.create(status: 'created', rating: 4)
post1.comments.create(status: 'approved', rating: 5)
post1.comments.create(status: 'deleted', rating: 0)

post2.comments.create(status: 'approved', rating: 3)
post2.comments.create(status: 'approved', rating: 5)
