use IR

select d.TipoCancelamento, d.NSU, 
		d.NroAutorizacao, d.TID, 
		d.Adquirente, d.Bandeira, 
		d.Estabelecimento, d.NroCartao, 
		d.Tipo, convert(varchar, d.DtVenda, 103) as DtVenda, 
		convert(varchar, d.DtCancelamento, 103) as DtCancelamento, d.VlrBruto, 
		d.VlrBrutoCancelamento
from dimTransacaoAdquirente a
inner join fatTransacaoAdquirente b on a.IdTransacaoAdquirente = b.IdTransacaoAdquirente
inner join fatCancelamento c on b.IdTransacaoAdquirente = c.IdTransacaoAdquirente
inner join dimCancelamento d on c.IdCancelamento = d.IdCancelamento
where b.IdStatusCancelamento = 5
order by Adquirente, a.IdTransacaoAdquirente, d.DtCancelamento


