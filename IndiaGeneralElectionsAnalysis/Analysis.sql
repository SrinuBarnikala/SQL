-- Total Seats
select count(Parliament_Constituency) as Total_Seats 
from constituencywise_results

-- Total Seats available for each state
select 
		s.State ,
		count(constituency) as Total_Seats
from statewise_results sr
join
states s on s.State_ID=sr.State_ID
group by s.State
order by s.State

-- Adding Column which give alliance name for each party in partywise_results table

alter Table partywise_results add party_alliance varchar(100)-- Adding column

update partywise_results
set party_alliance='NDA' 
where party in
(
'Bharatiya Janata Party - BJP',
'Telugu Desam - TDP',
'Janata Dal  (United) - JD(U)',
'Shiv Sena - SHS',
'AJSU Party - AJSUP',
'Apna Dal (Soneylal) - ADAL',
'Asom Gana Parishad - AGP',
'Hindustani Awam Morcha (Secular) - HAMS',
'Janasena Party - JnP',
'Janata Dal  (Secular) - JD(S)',
'Lok Janshakti Party(Ram Vilas) - LJPRV',
'Nationalist Congress Party - NCP',
'Rashtriya Lok Dal - RLD',
'Sikkim Krantikari Morcha - SKM',
'United People’s Party, Liberal - UPPL'
)

update partywise_results
set party_alliance='I.N.D.I.A ' 
where party in
(
'Indian National Congress - INC',
'Aam Aadmi Party - AAAP',
'All India Trinamool Congress - AITC',
'Bharat Adivasi Party - BHRTADVSIP',
'Communist Party of India  (Marxist) - CPI(M)',
'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
'Communist Party of India - CPI',
'Dravida Munnetra Kazhagam - DMK',
'Indian Union Muslim League - IUML',
'Nat`Jammu & Kashmir National Conference - JKN',
'Jharkhand Mukti Morcha - JMM',
'Jammu & Kashmir National Conference - JKN',
'Kerala Congress - KEC',
'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
'Rashtriya Janata Dal - RJD',
'Rashtriya Loktantrik Party - RLTP',
'Revolutionary Socialist Party - RSP',
'Samajwadi Party - SP',
'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
'Viduthalai Chiruthaigal Katchi - VCK'
)

update partywise_results
set party_alliance='Others' 
where party in
(
'Yuvajana Sramika Rythu Congress Party - YSRCP',
'Independent - IND',
'Voice of the People Party - VOTPP',
'Zoram People’s Movement - ZPM',
'All India Majlis-E-Ittehadul Muslimeen - AIMIM',
'Aazad Samaj Party (Kanshi Ram) - ASPKR',
'Shiromani Akali Dal - SAD'
)


/*
======================================
NDA
======================================
*/

-- Seats won by NDA
select 
		sum(won) as TotalSeatsWonByNDA 
from partywise_results
where party_alliance='NDA'
-- Seats won by each party in NDA
select 
		party,
		Won
from partywise_results
where party_alliance='NDA'
order by won desc

/*
======================================
I.N.D.I.A
======================================
*/

-- Seats won by I.N.D.I.A
select 
		sum(won) as TotalSeatsWonBy_INDI_Alliance
from partywise_results
where party_alliance='I.N.D.I.A'
-- Seats won by each party in I.N.D.I.A
select 
		party,
		Won
from partywise_results
where party_alliance='I.N.D.I.A'
order by won desc

/*
======================================
Others
======================================
*/
-- Seats won by Others
select 
		sum(won) as TotalSeatsWonByOthers 
from partywise_results
where party_alliance='Others'

-- Seats won by each party in Others
select 
		party,
		Won
from partywise_results
where party_alliance='Others'
order by won desc
/*
==================
Overall results
==================
*/
select 
		party_alliance,
		sum(won) as Seats_won
from partywise_results
group by party_alliance
order by sum(won) desc

-- Party alliance seats won by state wise
with cte as
(
select
		pr.party_alliance,
		s.State,
		count(cr.S_NO) as seats_won
from constituencywise_results cr
join  statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
join partywise_results pr on cr.Party_ID=pr.Party_ID
join states s on s.State_ID=sr.State_ID
group by pr.party_alliance,s.State
)
SELECT
    [State],
    SUM(CASE WHEN party_Alliance = 'NDA' THEN Seats_won ELSE 0 END) AS NDA,
    SUM(CASE WHEN party_Alliance = 'I.N.D.I.A' THEN Seats_won ELSE 0 END) AS [I.N.D.I.A],
    SUM(CASE WHEN party_Alliance = 'Others' THEN Seats_won ELSE 0 END) AS Others
FROM
    cte -- Replace with your actual table name
GROUP BY
    [State]
ORDER BY
    [State];
------------------------------------ Or ------------------------------------------------
select
		s.State,
		sum(case 
				when pr.party_alliance='NDA' then 1 else 0 
			end
			) as [Seats won by NDA],
		sum(case 
				when pr.party_alliance='I.N.D.I.A' then 1 else 0 
			end
			) as [seats won by I.N.D.I.A ],
		sum(case 
				when pr.party_alliance='Others' then 1 else 0 
			end
			) as [Seats won by Others]

from constituencywise_results cr
join  statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
join partywise_results pr on cr.Party_ID=pr.Party_ID
join states s on s.State_ID=sr.State_ID
group by s.state


-- winning candidate name , party_name ,total votes , margin , constituency, state 
select
		cr.Winning_Candidate,
		cr.Constituency_Name,
		cr.Total_Votes,
		cr.Margin,
		pr.Party,
		pr.party_alliance,
		s.state
from constituencywise_results cr
join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
join partywise_results pr on cr.Party_ID=pr.Party_ID
join states s on s.State_ID=sr.State_ID

-- what is the distribution of EVM votes and Postal votes for a candidate in a specific constituency.
select 
		cd.Candidate,
		cd.Total_Votes,
		cd.of_Votes,
		cd.EVM_Votes,
		case 
			when cd.Total_Votes=0 then 0
			else round((cast(cd.EVM_Votes as float)/cast(cd.Total_Votes as float))*100,2)
		end as EVM_votes_pct,
		cd.Postal_Votes,
		case 
			when cd.Total_Votes=0 then 0
			else round((cast(cd.Postal_Votes as float)/cast (cd.Total_Votes as float))*100 ,2)
		end as Postal_votes_pct,
		cr.Constituency_Name
from constituencywise_details cd
join constituencywise_results cr  on cr.Constituency_ID=cd.Constituency_ID
where cr.Constituency_Name='ARANI'

-- Candidate with higher percentage of votes
select 
		cd.Candidate,
		cd.Party,
		cd.of_Votes,
		cd.Total_Votes,
		cr.Constituency_Name
from constituencywise_details cd
join constituencywise_results cr on cd.Constituency_ID=cr.Constituency_ID
where of_Votes=( 
				select max(of_Votes) from constituencywise_details
			    )

-- Votes Overview
select 
		sum(total_votes) as total_votes,
		sum(EVM_Votes) as total_evm_votes,
		sum(Postal_Votes) as total_postal_votes
from constituencywise_details

-- specific state wise results
select
		pr.Party,
		pr.party_alliance,
		count(cr.S_NO) as seats_won
from constituencywise_results cr
join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
join partywise_results pr on cr.Party_ID=pr.Party_ID
join states s on s.State_ID=sr.State_ID
where s.state ='Punjab'
group by pr.party,pr.party_alliance
order by pr.party,pr.party_alliance

--Top 10 candidates based on evm votes along with their consituency
with cte as
(
select 
		constituency_ID,
		max(EVM_Votes) as EVM_Votes
from constituencywise_details
group by Constituency_ID
),
cte2 as 
(
select 
		cr.Winning_Candidate,
		cr.Constituency_Name,
		cte.EVM_Votes
from cte
join constituencywise_results cr on cr.Constituency_ID=cte.constituency_ID
)
select top 10
		winning_candidate,
		constituency_Name,
		EVM_Votes
from cte2
order by EVM_Votes desc

-- Which candidate won , which candidate runner up for each constituency in a state.
select 
		sr.Constituency,
		Leading_Candidate as winning_candidate,
		Trailing_Candidate as runner_up_candidate
from statewise_results sr
join states s on s.State_ID=sr.State_ID
where s.state='Uttar Pradesh'

-- StateWise : no of seats , no of candidates , no of parties , total votes , evm and postal votes breakdown
select 
		s.state,
		count(distinct cr.Constituency_Name) as no_of_seats,
		count(distinct party ) as no_of_parties,
		count(cd.candidate) as no_of_candidates,
		sum(cd.total_votes) as total_votes,
		sum(cd.evm_votes) as EVM_Votes,
		sum(cd.postal_votes) as Postal_votes		
from constituencywise_details cd
join constituencywise_results  cr on cr.Constituency_ID=cd.Constituency_ID
join statewise_results sr on sr.Parliament_Constituency=cr.Parliament_Constituency
join states s on s.State_ID=sr.State_ID
group by s.state
order by s.state

-- Alliance , constituency and % of votes got.
with cte as
(
select 
		pr.party_alliance,
		cr.Constituency_ID,
		max(cr.Total_Votes) as votes_to_winning_party,
		sum(cd.total_votes)  as total_votes
from partywise_results pr
join constituencywise_results cr on pr.Party_ID=cr.Party_ID
join constituencywise_details cd on cr.Constituency_ID=cd.Constituency_ID
group by pr.party_alliance,cr.Constituency_ID
)
select
		party_alliance,
		Constituency_ID,
		case 
			when total_votes=0 then 100.00
			else round(cast(votes_to_winning_party as float)/cast(total_votes as float)*100,2)
		end as votes_pct
from cte
order by votes_pct


