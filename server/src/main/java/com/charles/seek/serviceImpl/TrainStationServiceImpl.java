package com.charles.seek.serviceImpl;

import com.charles.seek.model.ticket.TrainStationModel;
import com.charles.seek.repository.TrainStationRepository;
import com.charles.seek.service.TrainStationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TrainStationServiceImpl implements TrainStationService {

    private final TrainStationRepository stationRepository;

    @Override
    public TrainStationModel save(TrainStationModel station) {
        return stationRepository.save(station);
    }

    @Override
    public boolean existsByCode(String code) {
        return stationRepository.existsByStationCode(code);
    }

    @Override
    public Optional<TrainStationModel> findByCode(String code) {
        return stationRepository.findByStationCode(code);
    }

    @Override
    public List<TrainStationModel> searchByKeyword(String keyword) {
        String kw = keyword == null ? "" : keyword.trim();
        if (kw.isEmpty()) {
            return listAllOrderedByName();
        }
        return stationRepository.findByNameContainingIgnoreCaseOrCityContainingIgnoreCase(kw, kw);
    }

    @Override
    public List<TrainStationModel> listAllOrderedByName() {
        return stationRepository.findAll(Sort.by(Sort.Direction.ASC, "name"));
    }
}