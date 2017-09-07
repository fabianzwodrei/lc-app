require 'json'

Member.create!([
  {first_name: 'Tim',last_name:'Nachname', email: 'tim@mitglieder.com',
   password: 'password1', password_confirmation: 'password1',
   fee_payment: FeePayment.create(account_details: 'tims kontonummer',paid: false), annotation: Annotation.create},
  {first_name: 'Tina',last_name:'Nachname', email: 'tina@interneorga.com',
   password: 'password1', password_confirmation: 'password1',
    departments:[1],
   fee_payment: FeePayment.create(account_details: 'tinas kontonummer',paid: false), annotation: Annotation.create},
  {first_name: 'Sabine',last_name:'Nachname', email: 'sabine@mandatsverwaltung.com',
   password: 'password1', password_confirmation: 'password1',
     departments:[0],
    fee_payment: FeePayment.create(account_details: 'sabines kontonummer',paid: false), annotation: Annotation.create},
  {first_name: 'Hans' ,last_name:'Nachname', email: 'hans@mandatsverwaltung.com',
    password: 'password1', password_confirmation: 'password1',
     departments:[0],
   fee_payment: FeePayment.create(account_details: 'hans kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Leif',last_name:'Nachname', email: 'leif@finanzen.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[5],
    fee_payment: FeePayment.create(account_details: 'leifs kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Sonja',last_name:'Nachname', email: 'sonja@schulungen.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[4],
   fee_payment: FeePayment.create(account_details: 'sonjas kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Leonie',last_name:'Nachname', email: 'leonie@netzwerk.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[2],
   fee_payment: FeePayment.create(account_details: 'leonies kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Tammy',last_name:'Nachname', email: 'tammy@oeffentlichkeit.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[3],
   fee_payment: FeePayment.create(account_details: 'tammys kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Svenja',last_name:'Nachname', email: 'svenja@mitglieder.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[],
   fee_payment: FeePayment.create(account_details: 'svenjas kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Martha',last_name:'Nachname', email: 'martha@sprechstunde.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[7],
   fee_payment: FeePayment.create(account_details: 'marthas kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Fatima',last_name:'Nachname', email: 'fatima@rechteverwaltung.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[8],
   fee_payment: FeePayment.create(account_details: 'fatimas kontonummer', paid: false), annotation: Annotation.create},
  {first_name: 'Olga',last_name:'Nachname', email: 'olga@vorstand.com',
   password: 'password1', password_confirmation: 'password1',
   departments:[6],
   fee_payment: FeePayment.create(account_details: 'olgas kontonummer', paid: false), annotation: Annotation.create}
])

0...8.times do |i|
  Conversation.create(department_id: i)
end

30.times do |i|
  Message.create!(
      {text:"Mandatsverwaltung - Nachricht #{i}",conversation_id: Conversation.where(department_id: 0).first.id})
end

30.times do |i|
  Message.create!(
      {text:"Interne Organisation - Nachricht #{i}",conversation_id:Conversation.where(department_id: 1).first.id})
end

Message.create!(
    {text:"eine Nachricht",conversation_id:1, member_id: (Member.find_by_email('sabine@mandatsverwaltung.com')).id})

Message.create!(
    {text:"eine Nachricht",conversation_id:2, member_id: (Member.find_by_email('tina@interneorga.com')).id})



Person.create!([    {        first_name: "Yasemin", last_name: "Meier",        email: "yasemin@yasemin.com",        phone: "12345",        languages: "Arabisch, English",        role: "client", department_id: 0    } ])

file = File.read('db/seed_users.json')
users_hash = JSON.parse(file)

i = 0
users_hash.each do |uhash|

  department_id = nil

  if i % 3 == 0
    role = 'client'
    department_id = 0
  elsif i % 2 == 0
    role = 'consultant'
    department_id = 0
  else
    role = 'contact'
    department_id = 3
  end

  Person.create!(
    {
       first_name: uhash["name"]["first"].capitalize,
       last_name: uhash["name"]["last"].capitalize,
       email: uhash["email"],
       phone: uhash["phone"],
       languages: uhash["nat"],
       role: role,
       department_id: department_id
     }
  )
  i+=1
end



Inquiry.create!([
    {title: "Sachstandsanfrage Eins", simple: "true", done: false,
     member: Member.find_by_email("hans@mandatsverwaltung.com"),
     client_id: 2,
     description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    },
    {title: "Sachstandsanfrage Zwei", simple: "true", done: true,
     member: Member.find_by_email("hans@mandatsverwaltung.com") ,
     client_id: 4,
     description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    },
    {title: "Sachstandsanfrage Drei", simple: "true", done: false,
     client_id: 1,
     description: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
    }
])
27.times do |i|
  Inquiry.create!([
      {title: "Anfrage #{i}", simple: "true", done: true, client_id: 1 }
  ])
end





16.times do |i|
  Mandate.create!({
    title: "Mandat "+(i+3).to_s,
    description: "Beschreibung des Mandats, Nr. "+(i+3).to_s,
    status: "vacant",
    code: (SecureRandom.urlsafe_base64 8)
  })
end

40.times do |i|
  Mandate.create!({
    title: "Mandat "+(i+3).to_s,
    description: "Beschreibung des Mandats, Nr. "+(i+3).to_s,
    status: "done",
    client: Person.find_by_first_name("Yasemin"),
    code: (SecureRandom.urlsafe_base64 8)
  })
end

Mandate.create!({
  title: "Mandat 1",
  description: "Beschreibung des Mandats, Nr. 1",
  status: "vacant",
  client: Person.find_by_first_name("Yasemin"),
  code: (SecureRandom.urlsafe_base64 8)
}).assignments.create!([{
  member: Member.find_by_email("tim@mitglieder.com")
}, {
  member: Member.find_by_email("svenja@mitglieder.com")
}
])

Mandate.create!({
  title: "Mandat 2",
  description: "Beschreibung des Mandats, Nr. 2",
  status: "active",
  code: (SecureRandom.urlsafe_base64 8),
  client: Person.find_by_first_name("Yasemin")
}).assignments.create!({
  member: Member.find_by_email("tim@mitglieder.com")
})

Mandate.create!({
  title: "Mandat 3",
  description: "Beschreibung des Mandats, Nr. 3",
  status: "active",
  code: (SecureRandom.urlsafe_base64 8),
  client: Person.find_by_first_name("Yasemin")
}).assignments.create!({
  member: Member.find_by_email("tim@mitglieder.com"),
  approved: true
})





## courses for tims qualification

c=Course.create!({
   title: "Schulung module-2, die Tim bestanden hat",
   dates: ['2017-01-01','31-01-2017'],
   where: 'Raum 102',
   module: 'module-2',
   qualification_date: Date.yesterday
})
c.attendances.create({
   member: Member.find_by_email('tim@mitglieder.com'),
   passed: true
})
c.update(archive:true)
c=Course.create!({
   title: "Schulung module-1-lecture, die Tim bestanden hat",
   dates: ['2017-01-01','31-01-2017'],
   where: 'Raum 102',
   module: 'module-1-lecture',
})
c.attendances.create({
   member: Member.find_by_email('tim@mitglieder.com'),
   permitted: true, passed: true
})
c.update(archive:true)
c=Course.create!({
   title: "Schulung module-1-workshop, die Tim bestanden hat",
   dates: ['2017-01-01','31-01-2017'],
   where: "Raum 101",
   module: 'module-1-workshop',
})
c.attendances.create({
   member: Member.find_by_email('tim@mitglieder.com'),
   passed: true
})
c.update(archive:true)
c=Course.create!({
   title: "Noch eine Schulung module-2, die Tim bestanden hat",
   dates: ['2017-01-01','31-01-2017'],
   where: "Raum 101",
   module: 'module-2',
   qualification_date: Date.yesterday
})
c.attendances.create({
   member: Member.find_by_email('tim@mitglieder.com'),
   passed: true
})
c.update(archive:true)

## active courses

Course.create!({
   title: "Schulung mit max. Teilnehmerzahl(1) und Bewerbungsphase",
   dates: ['2017-01-01','31-01-2017'],
   where: "Raum 102",
   module: 'module-1-workshop',
   archive: false,
   permission_required: true,
   limit: 1,
   conversation: Conversation.create()
}).attendances.create({
   member: Member.find_by_email('svenja@mitglieder.com'),
   permitted: false
})

Course.create!({
     title: "Schulung ohne max. Teilnehmerzahl mit Direktteilnahme",
     dates: ['2017-01-01','31-01-2017'],
     where: "Raum 101",
     module: 'module-1-lecture',
     conversation: Conversation.create()
 })

41.times do |i|
  c=Course.create!({
       title: "Archivierte Schulung #{i}",
       dates: ['2017-01-01','31-01-2017'],
       where: "Raum 101",
       module: 'module-1-lecture',
       conversation: Conversation.create()
   })
  c.update!(archive:true)
end

## consultations

Consultation.create!({
   title: "Sprechstunde I",
   dates: ['2017-01-01'],
   where: "Raum 101",
   archive: false,
   permission_required: true,
   limit: 6
})
Consultation.create!({
   title: "Sprechstunde II",
   dates: ['2017-01-01'],
   where: "Raum 101",
   archive: false,
   permission_required: true,
   limit: 6
})
41.times do |i|
  Consultation.create!({
     title: "Archivierte Sprechstunde #{i}",
     dates: ['2017-01-01'],
     where: "Raum 101",
     archive: true,
     permission_required: true,
     limit: 6
  })
end


11.times do |i|
  Event.create!({
       title: "Archiviertes Arbeittreffen #{i}",
       dates: ['2017-01-01'],
       where: "Raum 1111",
       archive: true,
       department_id: 0
   })
end




tim = Member.find_by_email("tim@mitglieder.com")
some_mandate = Mandate.where(title: "Mandat 3").first
3.times do |i|
  Task.create!({
    member_id: tim.id,
    title: "Private Aufgabe #{i}"
  })
end
3.times do |i|
  Task.create!({
    member_id: tim.id,
    mandate_id: some_mandate.id,
    title: "Mandatsaufgabe #{i}"
  })
end


