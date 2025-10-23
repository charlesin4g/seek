package com.charles.seek.controller;

import com.charles.seek.dto.ticket.request.AddTicketRequest;
import com.charles.seek.dto.ticket.request.EditTicketRequest;
import com.charles.seek.model.ticket.TicketModel;
import com.charles.seek.model.ticket.AirportModel;
import com.charles.seek.repository.AirportRepository;
import com.charles.seek.service.TicketService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;
import org.modelmapper.ModelMapper;

@RestController
@RequestMapping("/api/ticket")
@RequiredArgsConstructor
@Validated
@Tag(name = "票据管理", description = "票据相关操作")
public class TicketController {

    private final TicketService ticketService;
    private final ModelMapper mapper;
    private final AirportRepository airportRepository;

    /**
     * 创建票据
     */
    @PostMapping("/add")
    public ResponseEntity<TicketModel> add(@Valid @RequestBody AddTicketRequest req) {
        TicketModel t = mapper.map(req, TicketModel.class);
        return ResponseEntity.ok(ticketService.save(t));
    }

    /**
     * 编辑票据
     */
    @PutMapping("/edit")
    public ResponseEntity<TicketModel> edit(@RequestParam(name = "ticketId") Long ticketId,
                                            @Valid @RequestBody EditTicketRequest req) {
        return ticketService.updateTicket(ticketId, req)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    /**
     * 按所属用户查询票据（按出发时间倒序）
     */
    @GetMapping("/owner")
    public ResponseEntity<List<TicketModel>> byOwner(
            @RequestParam(name = "owner") @NotBlank @Size(max = 50) String owner) {
        return ResponseEntity.ok(ticketService.findByOwner(owner));
    }

    /**
     * 按班次查询票据（按出发时间倒序）
     */
    @GetMapping("/travelNo")
    public ResponseEntity<List<TicketModel>> byTravelNo(
            @RequestParam(name = "travelNo") @NotBlank @Size(max = 20) String travelNo) {
        return ResponseEntity.ok(ticketService.findByTravelNo(travelNo));
    }

    /**
     * 根据 IATA 代码查询机场详情
     */
    @GetMapping("/airport")
    public ResponseEntity<AirportModel> getAirportByIata(
            @RequestParam(name = "iata") @NotBlank @Size(max = 3) String iata) {
        String code = iata.trim().toUpperCase();
        return airportRepository.findByIataCode(code)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
