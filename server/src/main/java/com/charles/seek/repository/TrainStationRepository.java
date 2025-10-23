package com.charles.seek.repository;

import com.charles.seek.model.ticket.TrainStationModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface TrainStationRepository extends JpaRepository<TrainStationModel, Long> {
    boolean existsByStationCode(String stationCode);
    Optional<TrainStationModel> findByStationCode(String stationCode);

    List<TrainStationModel> findByNameContainingIgnoreCaseOrCityContainingIgnoreCase(String name, String city);

    @Query("SELECT s FROM TrainStationModel s")
    List<TrainStationModel> findAllStations(Sort sort);
}