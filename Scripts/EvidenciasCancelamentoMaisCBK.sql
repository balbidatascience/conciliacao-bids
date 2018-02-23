use IR

select  d.Adquirente, 
		d.TipoCancelamento, d.NSU, 
		d.NroAutorizacao, d.TID, 
		d.Bandeira, 
		d.Estabelecimento, d.NroCartao, 
		d.Tipo, convert(varchar, d.DtVenda, 103) as DtVenda, 
		convert(varchar, d.DtCancelamento, 103) as DtCancelamento, d.VlrBruto, 
		d.VlrBrutoCancelamento
from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
inner join fatCancelamento c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
inner join dimCancelamento d on c.IdCancelamento = d.IdCancelamento
where b.IdStatusCancelamento = 5
and d.DtVenda >= '6/10/2017'
order by Adquirente, a.IdTransacaoAdquirente, d.DtCancelamento


select * from dimTransacaoAdquirente where TID = '8eb1031e676f489b'
select * from fatTransacaoAdquirente where IdTransacaoAdquirente = 

