post1 = Post.create(title: "First post!")
post2 = Post.create(title: "Second post!")

post1.comments.create(status: 'created', rating: 4)
post1.comments.create(status: 'approved', rating: 5)
post1.comments.create(status: 'deleted', rating: 0)

post2.comments.create(status: 'approved', rating: 3)
post2.comments.create(status: 'approved', rating: 5)

teacher1 = Teacher.create name: 'Teacher 1'
teacher2 = Teacher.create name: 'Teacher 2'
student1 = Student.create name: 'Student 1'
student2 = Student.create name: 'Student 2'
student3 = Student.create name: 'Student 3'
student4 = Student.create name: 'Student 4'
teacher1.students = [student1]
teacher2.students = [student2, student3, student4]
