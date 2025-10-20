package com.charles.seek.serviceImpl;

import com.charles.seek.model.ticket.TicketModel;
import com.charles.seek.repository.TicketRepository;
import com.charles.seek.service.TicketService;
import com.charles.seek.dto.ticket.request.EditTicketRequest;
import org.modelmapper.ModelMapper;
import org.modelmapper.TypeMap;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TicketServiceImpl implements TicketService {

    private final TicketRepository ticketRepository;
    private final ModelMapper mapper;

    @Override
    public TicketModel save(TicketModel ticket) {
        return ticketRepository.save(ticket);
    }

    @Override
    public Optional<TicketModel> findById(Long id) {
        return ticketRepository.findById(id);
    }

    @Override
    public List<TicketModel> findByOwner(String owner) {
        return ticketRepository.findByOwnerOrderByDepartureTimeDesc(owner);
    }

    @Override
    public List<TicketModel> findByTravelNo(String travelNo) {
        return ticketRepository.findByTravelNoOrderByDepartureTimeDesc(travelNo);
    }

    @Override
    public void deleteById(Long id) {
        ticketRepository.deleteById(id);
    }

    // 新增：编辑票据
    @Override
    public Optional<TicketModel> updateTicket(Long ticketId, EditTicketRequest req) {
        return ticketRepository.findById(ticketId)
                .map(existing -> {
                    mapper.getConfiguration().setSkipNullEnabled(true);
                    TypeMap<EditTicketRequest, TicketModel> typeMap = mapper.getTypeMap(EditTicketRequest.class, TicketModel.class);
                    if (typeMap == null) {
                        typeMap = mapper.createTypeMap(EditTicketRequest.class, TicketModel.class);
                        typeMap.addMappings(m -> m.skip(TicketModel::setId));
                    }
                    mapper.map(req, existing);
                    return ticketRepository.save(existing);
                });
    }
}